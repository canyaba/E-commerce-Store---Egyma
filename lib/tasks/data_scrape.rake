# frozen_string_literal: true

require Rails.root.join('lib/darebee_scraped_seed_data')
require Rails.root.join('lib/wger_seed_data')

namespace :data do
  desc 'Scrape DAREBEE metadata into a committed seed snapshot'
  task :scrape_darebee, [:target_count] => :environment do |_task, args|
    target_count = args[:target_count].presence&.to_i || DarebeeScrapedSeedData::DEFAULT_TARGET_COUNT
    records = DarebeeScrapedSeedData.build_snapshot(target_count: target_count)
    DarebeeScrapedSeedData.save_snapshot!(records: records)

    puts "Saved #{records.count} DAREBEE records to #{DarebeeScrapedSeedData.default_snapshot_path}"
  end

  desc 'Fetch Wger API metadata into committed product and category seed snapshots'
  task :fetch_wger, [:target_count] => :environment do |_task, args|
    target_count = args[:target_count].presence&.to_i || WgerSeedData::DEFAULT_TARGET_COUNT
    categories, exercises = WgerSeedData.build_snapshots(target_count: target_count)
    WgerSeedData.save_snapshots!(categories: categories, exercises: exercises)

    puts "Saved #{categories.count} Wger categories to #{WgerSeedData.default_categories_snapshot_path}"
    puts "Saved #{exercises.count} Wger exercises to #{WgerSeedData.default_exercises_snapshot_path}"
  end
end
