# frozen_string_literal: true

require 'test_helper'
require Rails.root.join('lib/darebee_scraped_seed_data')

class DarebeeScrapedSeedDataTest < ActiveSupport::TestCase
  test 'extract_catalog_entries normalizes unique program urls' do
    html = file_fixture('darebee_programs_index.html').read

    entries = DarebeeScrapedSeedData.extract_catalog_entries(
      html: html,
      url_fragment: '/programs/',
      source_type: 'program'
    )

    assert_equal 2, entries.count
    assert_equal 'https://www.darebee.com/programs/power-up.html', entries.first[:url]
  end

  test 'build_snapshot_record derives metadata for mobility workout' do
    html = file_fixture('darebee_sample_workout.html').read

    record = DarebeeScrapedSeedData.build_snapshot_record(
      url: 'https://www.darebee.com/workouts/hip-opener-workout.html',
      source_type: 'workout',
      html: html
    )

    assert_equal 'Hip Opener Workout', record[:source_title]
    assert_includes record[:category_names], 'Mobility & Recovery'
    assert_equal 'all-levels', record[:difficulty_hint]
    assert_equal 'single-session workout', record[:duration_hint]
    assert_equal 'bodyweight', record[:equipment_hint]
    assert_match(/movement quality/i, record[:generated_description])
  end

  test 'snapshot records load into seed-safe product definitions' do
    records = DarebeeScrapedSeedData.seed_product_definitions(
      path: DarebeeScrapedSeedData.default_snapshot_path
    )
    titles = records.pluck(:title)

    assert_operator records.count, :>=, 100
    assert(records.all? { |record| record[:title].present? })
    assert(records.all? { |record| record[:category_names].present? })
    assert_equal titles.uniq.count, records.count
  end
end
