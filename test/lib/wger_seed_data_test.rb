# frozen_string_literal: true

require 'test_helper'
require 'tmpdir'
require Rails.root.join('lib/wger_seed_data')

class WgerSeedDataTest < ActiveSupport::TestCase
  test 'fetch_categories normalizes API category snapshots' do
    payload = JSON.parse(file_fixture('wger_categories_response.json').read)

    categories = WgerSeedData.fetch_categories(fetch_json: ->(_url) { payload })

    assert_equal 3, categories.count
    assert_equal 'Abs', categories.first[:source_category_name]
  end

  test 'build_exercise_snapshot_record maps API exercise metadata into local product fields' do
    exercise_payload = JSON.parse(file_fixture('wger_exercises_response.json').read)
    categories_payload = JSON.parse(file_fixture('wger_categories_response.json').read)
    category_lookup = categories_payload.fetch('results').to_h do |record|
      [record.fetch('id'), {
        source_category_id: record.fetch('id'),
        source_category_name: record.fetch('name')
      }]
    end

    record = WgerSeedData.build_exercise_snapshot_record(
      record: exercise_payload.fetch('results').first,
      category_lookup: category_lookup
    )

    assert_equal 'Push-Up', record[:source_name]
    assert_equal 'Chest', record[:source_category_name]
    assert_equal ['Strength Training'], record[:category_names]
    assert_match(/Wger API/i, record[:generated_description])
  end

  test 'snapshot records load into seed-safe product definitions' do
    exercise_payload = JSON.parse(file_fixture('wger_exercises_response.json').read)

    Dir.mktmpdir do |dir|
      path = File.join(dir, 'wger_exercises.json')
      File.write(path, JSON.pretty_generate(exercise_payload.fetch('results').map do |record|
        {
          source_name: record.fetch('name'),
          generated_title: "#{record.fetch('name')} Strength Guide",
          generated_description: 'Imported from Wger.',
          generated_price: 29,
          category_names: ['Strength Training']
        }
      end))

      records = WgerSeedData.seed_product_definitions(path: path)

      assert_equal 2, records.count
      assert(records.all? { |record| record[:title].present? })
      assert(records.all? { |record| record[:category_names].present? })
    end
  end
end
