class CreateUbuEntries < ActiveRecord::Migration
  def change
    create_table :ubu_entries do |t|
      t.integer :entry_type
      t.string :title
      t.string :href
      t.text :description
      t.string :artist, {:null => true}
      t.integer :scrape_event_id

      t.timestamps
    end
  end
end
