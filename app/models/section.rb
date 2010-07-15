class Section < Item

  def initialize(*params)
    super
    self.html_type = Section.html_types.invert["section"]
  end
end
