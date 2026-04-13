# frozen_string_literal: true

require Rails.root.join('lib/darebee_scraped_seed_data')

namespace :data do
  desc 'Scrape DAREBEE metadata into a committed seed snapshot'
  task :scrape_darebee, [:target_count] => :environment do |_task, args|
    target_count = args[:target_count].presence&.to_i || DarebeeScrapedSeedData::DEFAULT_TARGET_COUNT
    records = DarebeeScrapedSeedData.build_snapshot(target_count: target_count)
    DarebeeScrapedSeedData.save_snapshot!(records: records)

    puts "Saved #{records.count} DAREBEE records to #{DarebeeScrapedSeedData.default_snapshot_path}"
  end
end
