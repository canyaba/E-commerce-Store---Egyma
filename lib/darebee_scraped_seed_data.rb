# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'net/http'
require 'nokogiri'
require 'uri'

# rubocop:disable Metrics/ModuleLength
module DarebeeScrapedSeedData
  BASE_URL = 'https://www.darebee.com'
  WORKOUTS_INDEX_PATH = 'workouts.html'
  PROGRAMS_INDEX_PATH = 'programs.html'
  SNAPSHOT_PATH = File.expand_path('../db/data/darebee_products.json', __dir__)
  PAGE_SIZE = 15
  DEFAULT_TARGET_COUNT = 120

  CATEGORY_KEYWORDS = {
    'Strength Training' => %w[
      strength strong power powerlifting barbell conditioning athletic
      endurance explosive resistance core upper-body lower-body full-body
      push-up pull-up squat deadlift combat stamina hiit cardio circuit
      speed agility bodyweight challenge
    ],
    'Muscle Building' => %w[
      muscle hypertrophy builder volume growth split physique sculpt tone
      chest shoulders arms glutes legs mass shred abs lean aesthetic
    ],
    'Mobility & Recovery' => %w[
      mobility flexible flexibility recovery recover stretch stretching warm-up
      warmup yoga opener range motion flow joint hips hip shoulder shoulders
      spine thoracic cooldown decompress
    ]
  }.freeze

  EQUIPMENT_KEYWORDS = {
    'bodyweight' => %w[no-equipment bodyweight no equipment],
    'dumbbells' => %w[dumbbell dumbbells],
    'kettlebell' => %w[kettlebell kettlebells],
    'resistance band' => %w[band bands resistance-band resistance bands],
    'barbell' => %w[barbell barbell-based],
    'minimal equipment' => %w[minimal equipment home gym mat]
  }.freeze

  CURATED_MOBILITY_URLS = [
    "#{BASE_URL}/workouts/daily-mobility-workout.html",
    "#{BASE_URL}/workouts/post-workout-mobility-workout.html",
    "#{BASE_URL}/workouts/mobility-flow-workout.html"
  ].freeze

  module_function

  def default_snapshot_path
    SNAPSHOT_PATH
  end

  def build_snapshot(target_count: DEFAULT_TARGET_COUNT, fetch_html: method(:fetch_html))
    scraped_urls = collect_catalog_urls(target_count: target_count)
    scraped_urls |= curated_mobility_urls

    records = scraped_urls.filter_map do |entry|
      html = fetch_html.call(entry[:url])
      build_snapshot_record(url: entry[:url], source_type: entry[:source_type], html: html)
    end

    unique_records(records).first(target_count)
  end

  def save_snapshot!(records:, path: default_snapshot_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.pretty_generate(records))
  end

  def load_snapshot(path: default_snapshot_path)
    raise "Missing DAREBEE snapshot at #{path}" unless File.exist?(path)

    JSON.parse(File.read(path), symbolize_names: true)
  rescue JSON::ParserError => e
    raise "Unreadable DAREBEE snapshot at #{path}: #{e.message}"
  end

  def seed_product_definitions(path: default_snapshot_path)
    load_snapshot(path: path).map do |record|
      {
        title: record.fetch(:generated_title),
        price: record.fetch(:generated_price),
        description: record.fetch(:generated_description),
        category_names: record.fetch(:category_names)
      }
    end
  end

  # rubocop:disable Metrics/MethodLength
  def collect_catalog_urls(target_count:, fetch_html: method(:fetch_html))
    catalog_entries = collect_paginated_entries(
      index_path: PROGRAMS_INDEX_PATH,
      url_fragment: '/programs/',
      source_type: 'program',
      fetch_html: fetch_html,
      target_count: target_count
    )

    remaining_count = [target_count - catalog_entries.count, 0].max
    catalog_entries.concat(
      collect_paginated_entries(
        index_path: WORKOUTS_INDEX_PATH,
        url_fragment: '/workouts/',
        source_type: 'workout',
        fetch_html: fetch_html,
        target_count: remaining_count
      )
    )

    catalog_entries.uniq { |entry| entry[:url] }.first(target_count)
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def collect_paginated_entries(index_path:, url_fragment:, source_type:, fetch_html:, target_count:)
    return [] if target_count.zero?

    entries = []
    page_index = 0

    loop do
      html = fetch_html.call(index_url(index_path: index_path, page_index: page_index))
      page_entries = extract_catalog_entries(
        html: html,
        url_fragment: url_fragment,
        source_type: source_type
      )
      break if page_entries.empty?

      entries.concat(page_entries)
      break if entries.uniq { |entry| entry[:url] }.count >= target_count

      page_index += 1
      break if page_index > 20
    end

    entries.uniq { |entry| entry[:url] }
  end
  # rubocop:enable Metrics/MethodLength

  def extract_catalog_entries(html:, url_fragment:, source_type:)
    doc = Nokogiri::HTML(html)

    doc.css("a[href*='#{url_fragment}']").filter_map do |anchor|
      href = anchor['href']
      next if href.blank?
      next unless href.include?(url_fragment)

      { url: normalize_url(href), source_type: source_type }
    end.uniq
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def build_snapshot_record(url:, source_type:, html:)
    doc = Nokogiri::HTML(html)
    source_title = clean_title(doc.at_css('title')&.text)
    return nil if source_title.blank?

    classification_text = [
      source_title,
      URI(url).path.tr('/-', ' '),
      extract_page_excerpt(doc)
    ].join(' ').downcase

    category_names = category_names_for(classification_text: classification_text)
    return nil if category_names.empty?

    {
      source_title: source_title,
      source_url: url,
      source_type: source_type,
      category_names: category_names,
      difficulty_hint: difficulty_hint_for(classification_text),
      duration_hint: duration_hint_for(source_title: source_title, source_type: source_type),
      equipment_hint: equipment_hint_for(classification_text),
      generated_title: generated_title_for(source_title: source_title, source_type: source_type),
      generated_description: generated_description_for(
        source_title: source_title,
        source_type: source_type,
        category_names: category_names,
        classification_text: classification_text
      ),
      generated_price: generated_price_for(
        source_type: source_type,
        category_names: category_names,
        source_title: source_title
      )
    }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def fetch_html(url)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.read_timeout = 15

    request = Net::HTTP::Get.new(uri.request_uri, { 'User-Agent' => 'EgymaSeedScraper/1.0' })
    response = http.request(request)
    raise "Request failed for #{url}: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    response.body
  end

  def index_url(index_path:, page_index:)
    return "#{BASE_URL}/#{index_path}" if page_index.zero?

    "#{BASE_URL}/#{index_path}?start=#{page_index * PAGE_SIZE}"
  end

  def normalize_url(href)
    return href if href.start_with?('http://', 'https://')

    "#{BASE_URL}#{href}"
  end

  def curated_mobility_urls
    CURATED_MOBILITY_URLS.map { |url| { url: url, source_type: 'workout' } }
  end

  def clean_title(title)
    title.to_s.gsub(/\s+/, ' ').strip
  end

  def extract_page_excerpt(doc)
    doc.css('body').text.gsub(/\s+/, ' ').strip[0, 1_500]
  end

  def category_names_for(classification_text:)
    matched_categories = CATEGORY_KEYWORDS.filter_map do |category_name, keywords|
      category_name if keywords.any? { |keyword| classification_text.include?(keyword) }
    end

    matched_categories.presence || ['Strength Training']
  end

  def difficulty_hint_for(classification_text)
    return 'beginner' if classification_text.include?('beginner')
    return 'advanced' if classification_text.include?('advanced')
    return 'intermediate' if classification_text.include?('intermediate')

    'all-levels'
  end

  def duration_hint_for(source_title:, source_type:)
    matched_duration = source_title.downcase.match(/(\d+\s*(?:minute|min|day|week)s?)/)
    return matched_duration[1] if matched_duration

    source_type == 'program' ? 'multi-week program' : 'single-session workout'
  end

  def equipment_hint_for(classification_text)
    EQUIPMENT_KEYWORDS.each do |hint, keywords|
      return hint if keywords.any? { |keyword| classification_text.include?(keyword) }
    end

    'minimal equipment'
  end

  def generated_title_for(source_title:, source_type:)
    return source_title if source_title.match?(/program|workout|guide|flow|plan/i)

    "#{source_title} #{source_type == 'program' ? 'Program' : 'Workout'}"
  end

  # rubocop:disable Metrics/MethodLength
  def generated_description_for(source_title:, source_type:, category_names:, classification_text:)
    focus = description_focus_for(
      source_title: source_title,
      category_names: category_names
    )
    duration_hint = duration_hint_for(
      source_title: source_title,
      source_type: source_type
    )

    [
      "#{source_title} is an Egyma-ready #{source_type} inspired by public DAREBEE metadata.",
      "It suits customers looking for #{focus}",
      "with a #{difficulty_hint_for(classification_text)} approach, #{duration_hint},",
      "and #{equipment_hint_for(classification_text)}."
    ].join(' ')
  end
  # rubocop:enable Metrics/MethodLength

  def description_focus_for(source_title:, category_names:)
    if mobility_primary?(source_title: source_title, category_names: category_names)
      return 'mobility, recovery, and better movement quality'
    end

    return 'hypertrophy, physique structure, and consistent gym progress' if category_names.include?('Muscle Building')

    'structured training, conditioning, and practical strength development'
  end

  def generated_price_for(source_type:, category_names:, source_title:)
    base_price = source_type == 'program' ? 39 : 24
    return base_price if mobility_primary?(source_title: source_title, category_names: category_names)
    return base_price + 15 if category_names.include?('Muscle Building')

    base_price + 10
  end

  def mobility_primary?(source_title:, category_names:)
    category_names == ['Mobility & Recovery'] ||
      (
        category_names.include?('Mobility & Recovery') &&
        source_title.downcase.match?(/mobility|recovery|stretch|yoga|warm-up|warmup|flow|opener/)
      )
  end

  def unique_records(records)
    records.each_with_object([]) do |record, unique_records|
      next if unique_records.any? { |existing| existing[:generated_title] == record[:generated_title] }

      unique_records << record
    end
  end
end
# rubocop:enable Metrics/ModuleLength
