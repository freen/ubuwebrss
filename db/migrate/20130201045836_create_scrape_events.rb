class CreateScrapeEvents < ActiveRecord::Migration
  def change
    create_table :scrape_events do |t|

      t.timestamps
    end
  end
end
