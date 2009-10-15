class Item < ActiveRecord::Base

  #FIXME make this tests
  belongs_to :research
  validates_presence_of:research_id, :position
  validates_uniqueness_of :position, :scope => :research_id

end
