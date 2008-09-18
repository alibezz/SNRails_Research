
namespace :db do 
  desc 'Erase and fill database'
  task :populate => :environment  do
     require 'populator'
     [Research, User, Permission].each(&:delete_all)
     
     User.populate 1 do |user|
       user.login = 'admin'
       user.is_administrator = true
       user.crypted_password = '44d5d03bfe8570fbfaa630a3520b33724c397ea9' #encriptation for 123456 password
       user.email = 'admin@localhost'
     end 

     Research.populate 20 do |research|
       research.title = Populator.words(1..4).titleize
       research.subtitle = Populator.words(1.7).titleize
       research.introduction = Populator.sentences(2..10)
       User.populate 8 do |user|
         user.login = Populator.words(3)
         user.email = Populator.words(1) + '@localhost.com'
         Permission.populate 1 do |permission|
           permission.user_id = user.id
           permission.research_id = research.id
           permission.is_moderator = [true, false]
         end
       end
     end

  end
end
