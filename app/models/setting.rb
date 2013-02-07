class Setting < ActiveRecord::Base
  attr_accessible :key, :label, :value

  def self.getValue( key )
    setting = where('`key` = ?', key).first
    return nil if setting.nil?
    return setting[:value]
  end

  def self.getIntegerValue( key )
    return getValue( key ).to_i
  end
end
