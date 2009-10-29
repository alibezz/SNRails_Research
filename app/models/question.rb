class Question < Item

  has_many :item_values, :foreign_key => :item_id
  has_many :object_item_values, :foreign_key => :item_id

  validates_presence_of :info

end
