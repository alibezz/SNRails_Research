ActionController::Routing::Routes.draw do |map|

  map.resources :groups

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.resources :users
  map.resource :session

  map.resources :public do |p|
    p.resources :questionnaires, :collection => { :new => :post }
    p.resources :items
  end

  map.resources :questions, :controller => 'items', :has_many => :item_values

  # Route for survey
  map.namespace :survey do |survey|
    survey.resources :surveys, :member => { :charts => :get, :role_management => :get, :new_member => :put, :edit_member => :put, :remove_member => :get, :activate => :get } do |surveys|
      surveys.resources :items, :collection => {:reorder_items => :post, :reorder_pages => :post,                                                                            :set_item_to_page => :post},                                                                         :member => {:dependencies => :get, :filter => :post, :create_dependency => :post,                                                        :remove_dependency => :post, :remove_items => :get, :destroy_items => :post}
      surveys.resources :questions do |questions|
        questions.resources :item_values, :collection => {:reorder_item_values => :post}
      end
    end
 end

 # Route for admin
  map.namespace :admin do |admin|
  #  admin.resources :surveys, :member => { :role_management => :get, :new_member => :put, :edit_member => :put, :remove_member => :get }
    admin.resources :roles
  end
 
   #Route for doc plugin
  map.resources :doc

  #Mapping design block routes
  map.design_plugin

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "public"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
#  map.connect ':controller/:action/:id.:format'
end
