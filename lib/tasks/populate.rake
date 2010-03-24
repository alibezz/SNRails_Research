
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

    Role.create!(:name => 'Moderator', :permissions => ['survey_viewing', 'survey_editing', 'survey_erasing'])  
    Role.create!(:name => 'Editor', :permissions => ['survey_viewing', 'survey_editing'])  
    Role.create!(:name => 'Collaborator', :permissions => ['survey_viewing'])  

     User.populate 1 do |user|
     user.login = 'admin'
       user.administrator = true
       user.crypted_password = '44d5d03bfe8570fbfaa630a3520b33724c397ea9' #encriptation for 123456 password
       user.email = 'admin@localhost'
     end 

     Survey.populate 10 do |survey|
       survey.title = Populator.words(1..4).titleize
       survey.design_data = {:template => 'default', :theme => 'default', :icon_theme => 'default'}
       survey.subtitle = Populator.words(1.7).titleize
       survey.introduction = Populator.sentences(2..10)
       survey.is_private = [true, false]
       survey.number_of_pages = 1..9
       count = 0 
       Item.populate 5 do |item|
         count += 1
         item.info = Populator.words(5)
         item.survey_id = survey.id
         item.position = count
         item.page_id = 1..survey.number_of_pages
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
     Survey.find(:all).each do |survey|
       moderator = @users.first
       moderator.add_role(Role.find_by_name('Moderator'), survey)
       moderator.login = "moderator_#{survey.id}"
       moderator.name = moderator.login
       moderator.email = moderator.login + '@localhost.com'
       moderator.save!; moderator.reload
       @users.delete_at(0)

       editor = @users.first
       editor.add_role(Role.find_by_name('Editor'), survey)
       editor.login = "editor_#{survey.id}"
       editor.name = editor.login
       editor.email = editor.login + '@localhost.com'
       editor.save!; editor.reload
       @users.delete_at(0)

       collaborator = @users.first
       collaborator.add_role(Role.find_by_name('Collaborator'), survey)
       collaborator.login = "collaborator_#{survey.id}"
       collaborator.name = collaborator.login
       collaborator.email = collaborator.login + '@localhost.com'       
       collaborator.save!; collaborator.reload
       @users.delete_at(0)
     end
  end


  def erase
     [Environment, Survey, User, Permission, Item, ObjectItemValue, Questionnaire].each(&:delete_all)
  end


end
