class Zone < ActiveRecord::Base
  has_many :coords, class_name: 'ZoneCoordinate'
  accepts_nested_attributes_for :coords
end
