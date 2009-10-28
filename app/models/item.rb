class Item < ActiveRecord::Base

  belongs_to :research
  validates_presence_of:research_id, :position
  validates_uniqueness_of :position, :scope => :research_id
  has_many :item_values

   HTML_TYPES = ["multiple_selection",
    "single_selection",
    "pure_text"
  ]

  def is_text?
    self.html_type == "pure_text"
  end

protected
  def self.html_types
    HTML_TYPES
  end

end
