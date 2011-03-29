#Hacked created to solve a bug of compatibility between rails and gettext.
#Test if it's needed on new version of rails.
module ActionView
 class Base
   delegate :file_exists?, :to => :finder unless respond_to?(:file_exists?)
 end
end
