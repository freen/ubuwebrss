class ScrapeEvent < ActiveRecord::Base
  attr_accessible :entries_found
  has_many :ubu_entries
end
