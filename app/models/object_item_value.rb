class ObjectItemValue < ActiveRecord::Base
  belongs_to :item
  belongs_to :item_value
  belongs_to :questionnaire

  validates_presence_of :questionnaire_id
 
end
