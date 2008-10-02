class ItemValue < ActiveRecord::Base
  #FIXME make this tests
  validates_presence_of:item_id
#  validates_presence_of :info FIXME if type is text this is not true
  belongs_to :item
  validates_uniqueness_of :position, :scope => :item_id

  before_save do |item_value|
    item_value.position ||= (item_value.max("item_id = ?" % item_value) || 0) + 1 unless item_value.item.nil?
  end

end
