class Question < Item

  #FIXME make this tests
  has_many :item_values, :foreign_key => :item_id

  validates_presence_of :info

end
