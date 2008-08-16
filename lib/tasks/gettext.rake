#
# Added for Ruby-GetText-Package
#

require 'rails_research'

desc "Create mo-files for L10n"
task :makemo do
  require 'gettext/utils'
  GetText.create_mofiles(true, "po", "locale")
end

desc "Update pot/po files to match new version."
task :updatepo do
  require 'gettext/utils'
  GetText.update_pofiles('rails_research', Dir.glob("{app,lib}/**/*.{rb,rhtml,erb, rtex}"),
                         "rails_research #{RailsResearch::VERSION}")
end

# vim: ft=ruby
