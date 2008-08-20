class Research < ActiveRecord::Base
  has_many :items
  has_many :questions
end
