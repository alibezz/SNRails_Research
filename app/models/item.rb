class Item < ActiveRecord::Base

  belongs_to :research
  validates_presence_of:research_id, :position, :info
end
