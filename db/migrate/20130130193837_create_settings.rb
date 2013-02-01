class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :key
      t.string :label
      t.string :value

      t.timestamps
    end

    add_index :settings, [:key], {:unique => true}

    Setting.create 	:key => :scrape_interval,
    				:label => 'Scrape Interval',
    				:value => '12H'
  end
end
