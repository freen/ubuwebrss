class ScrapeEvent < ActiveRecord::Base
  attr_accessible :ubu_entries_count
  has_many :ubu_entries

  def self.get_last_with_entries
    self.where('ubu_entries_count > 0').limit(1).order('id desc').first
  end

end
