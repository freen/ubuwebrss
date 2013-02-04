class ScrapeEventEntriesFound < ActiveRecord::Migration
  def up
      add_column :scrape_events, :ubu_entries_count, :integer, :default => 0

      ScrapeEvent.reset_column_information
      ScrapeEvent.find(:all).each do |scrape|
      	ScrapeEvent.update_counters scrape.id, :ubu_entries_count => scrape.ubu_entries.size
      	scrape.save
      end
  end

  def down
      add_column :scrape_events, :ubu_entries_count
  end
end
