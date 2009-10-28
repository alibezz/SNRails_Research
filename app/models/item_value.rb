class ItemValue < ActiveRecord::Base

  validates_presence_of:item_id, :position
  
  validate do |b|
    b.has_info?
  end
 
  belongs_to :item
  validates_uniqueness_of :position, :scope => :item_id

  before_save do |item_value|
    item_value.position ||= (item_value.max("item_id = ?" % item_value) || 0) + 1 unless item_value.item.nil?
  end

  def has_info?
    unless self.item_id.nil?
      if Item.find(self.item_id).is_text? and self.info
        errors.add_to_base("Info must be blank.")
      elsif not Item.find(self.item_id).is_text? and self.info.nil?
        errors.add_to_base("Info must be blank.")
      end
    end
  end
end
