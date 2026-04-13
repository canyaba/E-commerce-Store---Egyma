# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'net/http'
require 'nokogiri'
require 'uri'

# rubocop:disable Metrics/ModuleLength
module WgerSeedData
  API_BASE_URL = 'https://wger.de/api/v2'
  DEFAULT_TARGET_COUNT = 40
  CATEGORIES_SNAPSHOT_PATH = File.expand_path('../db/data/wger_categories.json', __dir__)
  EXERCISES_SNAPSHOT_PATH = File.expand_path('../db/data/wger_exercises.json', __dir__)

  LOCAL_CATEGORY_KEYWORDS = {
    'Strength Training' => [
      'strength', 'back', 'chest', 'legs', 'shoulders', 'lower back',
      'olympic', 'full body', 'compound'
    ],
    'Muscle Building' => [
      'abs', 'calves', 'glutes', 'biceps', 'triceps', 'hypertrophy',
      'isolation', 'upper arms', 'lower arms'
    ],
    'Mobility & Recovery' => %w[
      stretching cardio warmup warm-up mobility yoga recovery rehabilitation
    ]
  }.freeze

  module_function

  def default_categories_snapshot_path
    CATEGORIES_SNAPSHOT_PATH
  end

  def default_exercises_snapshot_path
    EXERCISES_SNAPSHOT_PATH
  end

  def build_snapshots(target_count: DEFAULT_TARGET_COUNT, fetch_json: method(:fetch_json))
    categories = fetch_categories(fetch_json: fetch_json)
    category_lookup = categories.index_by { |category| category[:source_category_id] }
    exercises = fetch_exercises(
      target_count: target_count,
      fetch_json: fetch_json,
      category_lookup: category_lookup
    )

    [categories, exercises]
  end

  def save_snapshots!(categories:, exercises:, categories_path: default_categories_snapshot_path,
                      exercises_path: default_exercises_snapshot_path)
    FileUtils.mkdir_p(File.dirname(categories_path))
    FileUtils.mkdir_p(File.dirname(exercises_path))
    File.write(categories_path, JSON.pretty_generate(categories))
    File.write(exercises_path, JSON.pretty_generate(exercises))
  end

  def load_categories_snapshot(path: default_categories_snapshot_path)
    load_snapshot(path: path, label: 'Wger categories')
  end

  def load_exercises_snapshot(path: default_exercises_snapshot_path)
    load_snapshot(path: path, label: 'Wger exercises')
  end

  def seed_product_definitions(path: default_exercises_snapshot_path)
    load_exercises_snapshot(path: path).map do |record|
      {
        title: record.fetch(:generated_title),
        price: record.fetch(:generated_price),
        description: record.fetch(:generated_description),
        category_names: record.fetch(:category_names)
      }
    end
  end

  def fetch_categories(fetch_json: method(:fetch_json))
    fetch_paginated_results('exercisecategory/', fetch_json: fetch_json).filter_map do |record|
      source_category_id = value_for(record, 'id')
      source_category_name = normalize_text(value_for(record, 'name'))
      next if source_category_id.blank? || source_category_name.blank?

      {
        source_category_id: source_category_id,
        source_category_name: source_category_name
      }
    end
  end

  def fetch_exercises(target_count:, fetch_json:, category_lookup:)
    records = fetch_paginated_results(
      'exerciseinfo/',
      fetch_json: fetch_json,
      params: { language: 2 }
    ).filter_map do |record|
      build_exercise_snapshot_record(record: record, category_lookup: category_lookup)
    end

    unique_records(records).first(target_count)
  end

  # rubocop:disable Metrics/MethodLength
  def build_exercise_snapshot_record(record:, category_lookup:)
    source_name = source_name_for(record)
    source_api_id = value_for(record, 'id')
    return nil if source_name.blank? || source_api_id.blank?

    source_category_id, source_category_name = source_category_data_for(record, category_lookup:)
    source_equipment_names = equipment_names_for(record)
    source_level = normalize_text(value_for(record, 'level')) || 'all-levels'
    source_description = source_description_for(record)
    category_names = category_names_for(
      source_category_name: source_category_name,
      source_name: source_name,
      source_description: source_description
    )

    {
      source_name: source_name,
      source_api_id: source_api_id,
      source_api_url: "#{API_BASE_URL}/exerciseinfo/#{source_api_id}/",
      source_category_id: source_category_id,
      source_category_name: source_category_name,
      source_equipment_names: source_equipment_names,
      source_level: source_level,
      category_names: category_names,
      generated_title: generated_title_for(
        source_name: source_name,
        source_category_name: source_category_name,
        category_names: category_names
      ),
      generated_description: generated_description_for(
        source_name: source_name,
        source_category_name: source_category_name,
        source_description: source_description,
        source_equipment_names: source_equipment_names,
        source_level: source_level
      ),
      generated_price: generated_price_for(category_names: category_names)
    }
  end
  # rubocop:enable Metrics/MethodLength

  def fetch_json(url)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.read_timeout = 15

    request = Net::HTTP::Get.new(uri.request_uri, { 'User-Agent' => 'EgymaSeedImporter/1.0' })
    response = http.request(request)
    raise "Request failed for #{url}: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  def fetch_paginated_results(path, fetch_json:, params: {})
    next_url = build_url(path, params)
    results = []

    while next_url.present?
      payload = fetch_json.call(next_url)
      results.concat(Array(value_for(payload, 'results') || payload))

      next_link = value_for(payload, 'next')
      next_url = normalize_next_url(next_link)
    end

    results
  end

  def build_url(path, params)
    uri = URI.join("#{API_BASE_URL}/", path)
    uri.query = params.merge(limit: 50).to_query
    uri.to_s
  end

  def normalize_next_url(next_link)
    return if next_link.blank?

    next_link.start_with?('http') ? next_link : URI.join("#{API_BASE_URL}/", next_link).to_s
  end

  # rubocop:disable Metrics/MethodLength
  def source_category_data_for(record, category_lookup:)
    category_value = value_for(record, 'category')

    if category_value.is_a?(Hash)
      [
        value_for(category_value, 'id'),
        normalize_text(value_for(category_value, 'name'))
      ]
    else
      category_record = category_lookup[category_value]
      [
        category_value,
        category_record&.fetch(:source_category_name, nil)
      ]
    end
  end
  # rubocop:enable Metrics/MethodLength

  def equipment_names_for(record)
    Array(value_for(record, 'equipment')).filter_map do |entry|
      normalize_text(entry.is_a?(Hash) ? value_for(entry, 'name') : entry)
    end
  end

  def source_name_for(record)
    normalize_text(value_for(record, 'name')) ||
      normalize_text(value_for(preferred_translation_for(record), 'name'))
  end

  def source_description_for(record)
    plain_text_html(value_for(record, 'description')) ||
      plain_text_html(value_for(preferred_translation_for(record), 'description'))
  end

  def preferred_translation_for(record)
    translations = Array(value_for(record, 'translations'))
    translations.find { |translation| value_for(translation, 'language') == 2 } || translations.first || {}
  end

  def category_names_for(source_category_name:, source_name:, source_description:)
    classification_text = [
      source_category_name,
      source_name,
      source_description
    ].compact.join(' ').downcase

    categories = LOCAL_CATEGORY_KEYWORDS.each_with_object([]) do |(category_name, keywords), matched|
      matched << category_name if keywords.any? { |keyword| classification_text.include?(keyword) }
    end

    categories.presence || ['Strength Training']
  end

  def generated_title_for(source_name:, source_category_name:, category_names:)
    suffix =
      if category_names.include?('Mobility & Recovery')
        'Mobility Drill'
      elsif category_names.include?('Muscle Building')
        'Muscle Builder'
      else
        'Strength Guide'
      end

    return source_name if source_name.match?(/guide|drill|builder/i)

    [source_name, source_category_name, suffix].compact.join(' ').squeeze(' ')
  end

  def generated_description_for(
    source_name:,
    source_category_name:,
    source_description:,
    source_equipment_names:,
    source_level:
  )
    [
      "#{source_name} is seeded from the public Wger API.",
      "It is based on the source category #{source_category_name || 'general training'}",
      "with a #{source_level} difficulty profile",
      "#{equipment_text_for(source_equipment_names)}.",
      description_body_for(source_description)
    ].join(' ')
  end

  def generated_price_for(category_names:)
    return 22 if category_names == ['Mobility & Recovery']
    return 34 if category_names.include?('Muscle Building')

    29
  end

  def equipment_text_for(source_equipment_names)
    return 'and minimal equipment expectations' if source_equipment_names.blank?

    "and equipment cues including #{source_equipment_names.join(', ')}"
  end

  def description_body_for(source_description)
    if source_description.blank?
      return 'The imported record has been normalized into an Egyma-ready catalog description.'
    end

    [source_description.first(180).strip, 'This metadata has been normalized for the Egyma catalog.'].join(' ')
  end

  def plain_text_html(value)
    normalize_text(Nokogiri::HTML.fragment(value.to_s).text)
  end

  def normalize_text(value)
    value.to_s.gsub(/\s+/, ' ').strip.presence
  end

  def value_for(record, key)
    record[key] || record[key.to_sym]
  end

  def unique_records(records)
    records.each_with_object([]) do |record, unique_records|
      next if unique_records.any? { |existing| existing[:generated_title] == record[:generated_title] }

      unique_records << record
    end
  end

  def load_snapshot(path:, label:)
    raise "Missing #{label} snapshot at #{path}" unless File.exist?(path)

    JSON.parse(File.read(path), symbolize_names: true)
  rescue JSON::ParserError => e
    raise "Unreadable #{label} snapshot at #{path}: #{e.message}"
  end
end
# rubocop:enable Metrics/ModuleLength
