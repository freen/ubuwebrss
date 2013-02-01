class Setting < ActiveRecord::Base
  attr_accessible :key, :label, :value
end
