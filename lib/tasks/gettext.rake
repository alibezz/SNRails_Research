#
# Added for Ruby-GetText-Package
#

require 'rails_survey'

desc "Create mo-files for L10n"
task :makemo do
  require 'gettext/utils'
  GetText.create_mofiles(true, "po", "locale")
end

desc "Update pot/po files to match new version."
task :updatepo do
  require 'gettext/utils'
  GetText.update_pofiles('rails_survey', Dir.glob("{app,lib}/**/*.{rb,rhtml,erb, rtex}"),
                         "rails_survey #{RailsSurvey::VERSION}")
end

# vim: ft=ruby
