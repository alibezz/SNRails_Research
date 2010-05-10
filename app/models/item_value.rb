class ItemValue < ActiveRecord::Base

  validates_presence_of :item_id, :position
  
  validate do |b|
    b.has_info?
  end
 
  belongs_to :item
  has_and_belongs_to_many :conditionals, :class_name => "Question"

  before_save do |item_value|
    item_value.position ||= (item_value.max("item_id = ?" % item_value) || 0) + 1 unless item_value.item.nil?
  end

  def has_info?
    unless self.item_id.nil?
      if not Item.find(self.item_id).is_text? and self.info and self.info.empty?
        errors.add_to_base("#{t(:info_cant_be_blank)}")
      end
    end
  end

end
