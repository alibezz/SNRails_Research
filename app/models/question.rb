class Question < Item

  #FIXME make this tests
  has_many :answers, :foreign_key => :item_id

  validates_presence_of :info

end
