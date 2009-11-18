class ItemValue < ActiveRecord::Base

  validates_presence_of:item_id, :position
  
  validate do |b|
    b.has_info?
  end
 
  belongs_to :item
# no longer necessary  validates_uniqueness_of :position, :scope => :item_id

  before_save do |item_value|
    item_value.position ||= (item_value.max("item_id = ?" % item_value) || 0) + 1 unless item_value.item.nil?
  end

  def has_info?
    unless self.item_id.nil?
      if not Item.find(self.item_id).is_text? and self.info and self.info.empty?
        errors.add_to_base("Info can't be blank.")
      end
    end
  end
end
