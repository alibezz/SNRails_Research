
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

    Role.create!(:name => 'Moderator', :permissions => ['research_viewing', 'research_editing', 'research_erasing'])  
    Role.create!(:name => 'Editor', :permissions => ['research_viewing', 'research_editing'])  
    Role.create!(:name => 'Collaborator', :permissions => ['research_viewing'])  

     User.populate 1 do |user|
     user.login = 'admin'
       user.administrator = true
       user.crypted_password = '44d5d03bfe8570fbfaa630a3520b33724c397ea9' #encriptation for 123456 password
       user.email = 'admin@localhost'
     end 

     Research.populate 10 do |research|
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
     end
     User.populate 30 do |user|
       user.administrator = false
       user.crypted_password = '44d5d03bfe8570fbfaa630a3520b33724c397ea9' #encriptation for 123456 password
     end
     
     @users = User.find(:all, :conditions => {:administrator => false})
     Research.find(:all).each do |research|
       moderator = @users.first
       moderator.add_role(Role.find_by_name('Moderator'), research)
       moderator.login = "moderator_#{research.id}"
       moderator.name = moderator.login
       moderator.email = moderator.login + '@localhost.com'
       moderator.save!; moderator.reload
       @users.delete_at(0)

       editor = @users.first
       editor.add_role(Role.find_by_name('Editor'), research)
       editor.login = "editor_#{research.id}"
       editor.name = editor.login
       editor.email = editor.login + '@localhost.com'
       editor.save!; editor.reload
       @users.delete_at(0)

       collaborator = @users.first
       collaborator.add_role(Role.find_by_name('Collaborator'), research)
       collaborator.login = "collaborator_#{research.id}"
       collaborator.name = collaborator.login
       collaborator.email = collaborator.login + '@localhost.com'       
       collaborator.save!; collaborator.reload
       @users.delete_at(0)
     end
  end


  def erase
     [Environment, Research, User, Permission, Item, ObjectItemValue, Questionnaire].each(&:delete_all)
  end


end
