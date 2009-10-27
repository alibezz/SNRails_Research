class Item < ActiveRecord::Base

  #FIXME make this tests
  belongs_to :research
  validates_presence_of:research_id, :position
  validates_uniqueness_of :position, :scope => :research_id
  has_many :item_values

   HTML_TYPES = ["multiple_selection",
    "single_selection",
    "pure_text"
  ]

protected
  def self.html_types
    HTML_TYPES
  end

end
