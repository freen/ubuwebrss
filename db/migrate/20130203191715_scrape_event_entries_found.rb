class ScrapeEventEntriesFound < ActiveRecord::Migration
  def up
      add_column :scrape_events, :entries_found, :integer, :default => 0

      ScrapeEvent.reset_column_information
      ScrapeEvent.find(:all).each do |scrape|
      	ScrapeEvent.update_counters scrape.id, :entries_found => scrape.ubu_entries.size
      	scrape.save
      end
  end

  def down
      add_column :scrape_events, :entries_found
  end
end
