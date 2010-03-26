class Environment < ActiveRecord::Base

  acts_as_design :root => File.join('designs', 'environments')

  def self.default
    self.find_by_is_default(true)
  end

end
