class ScrapeEvent < ActiveRecord::Base
  attr_accessible :ubu_entries_count
  has_many :ubu_entries
end
