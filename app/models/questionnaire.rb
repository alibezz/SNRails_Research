class Questionnaire < ActiveRecord::Base
  has_many :object_item_values
end
