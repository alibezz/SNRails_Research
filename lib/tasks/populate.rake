
namespace :db do 

  desc 'Erase database'
  task :erase => :environment  do
    erase
  end

  desc 'Erase and fill database'
  task :populate => :environment  do
     require 'populator'

     erase
    
    env = Environment.new(:is_default => true)
    env.design_data = {:template => 'default', :theme => 'default', :icon_theme => 'default'}
    env.save!
 
     User.populate 1 do |user|
     user.login = 'admin'
       user.is_administrator = true
       user.crypted_password = '44d5d03bfe8570fbfaa630a3520b33724c397ea9' #encriptation for 123456 password
       user.email = 'admin@localhost'
     end 

     Research.populate 20 do |research|
       research.title = Populator.words(1..4).titleize
       research.design_data = {:template => 'default', :theme => 'default', :icon_theme => 'default'}
       research.subtitle = Populator.words(1.7).titleize
       research.introduction = Populator.sentences(2..10)
       research.is_private = [true, false]
       research.number_of_pages = 1..9
       count = 0 
       Item.populate 5 do |item|
         count += 1
         item.info = Populator.words(5)
         item.research_id = research.id
         item.position = count
         item.page_id = 1..research.number_of_pages
         item.type = ['Question', 'Section']
         #item.type = 'Item'
         if item.type == 'Question'
           item.max_answers = item.min_answers = 0
         #if item.type == 'Item'
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


  def erase
     [Environment, Research, User, Permission, Item, ObjectItemValue, Questionnaire].each(&:delete_all)
  end


end
