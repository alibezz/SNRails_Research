class Environment < ActiveRecord::Base

  #FIXME this is a hack to works design_data
#  class << self # Class methods
#    alias :all_columns :columns
#
#    def columns
#      all_columns.reject {|c| c.name == 'design_data'}
#    end
#  end 

  acts_as_design :root => File.join('designs', 'environments')

  acts_as_accessible

  PERMISSIONS['environment'] = {
    'administrator' => I18n.t(:permission_administrator)
  }

  def self.default
    self.find_by_is_default(true)
  end

end
