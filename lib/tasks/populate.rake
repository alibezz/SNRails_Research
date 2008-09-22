
namespace :db do 
  desc 'Erase and fill database'
  task :populate => :environment  do
     require 'populator'
     [Research, User, Permission, Item, Answer].each(&:delete_all)
     
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
       research.is_private = [true, false]
       research.number_of_pages = 1..9
       Item.populate 5 do |item|
         item.info = Populator.words(5)
         item.research_id = research.id
         item.page_id = 1..research.number_of_pages
         item.type = ['Question', 'Section']
         #item.type = 'Item'
         if item.type == 'Question'
         #if item.type == 'Item'
           Answer.populate 4 do |answer|
             answer.info = Populator.words(2)
             answer.item_id = item.id
           end
         end
       end
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
