class Answer < ActiveRecord::Base
  #FIXME make this tests
  validates_presence_of:item_id
  validates_presence_of :info
  validates_uniqueness_of :position, :scope => :item_id

  before_save do |answer|
    answer.position ||= (Answer.max("item_id = ?" % answer) || 0) + 1 unless answer.item.nil?
  end

end
