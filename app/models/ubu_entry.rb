class UbuEntry < ActiveRecord::Base
  attr_accessible :type, :artist, :description, :href, :title

  # Constant values also represent the relative priority of each entry type,
  # should multiple be discovered during the same scrape.

  # Note: Priority weights are defined by the visibility of each section on
  # the page, the center having the highest visibility, and the bottom-left
  # ("Recent Additions:") having the lowest

  TYPE_COLLECTION = 3
  TYPE_NEW_ADDITION = 2
  TYPE_RECENT_ADDITION = 1

  def is_collection?
    self.type == TYPE_COLLECTION
  end
  
  def is_new_addition?
    self.type == TYPE_NEW_ADDITION
  end
  
  def is_recent_addition?
    self.type == TYPE_RECENT_ADDITION
  end

end
