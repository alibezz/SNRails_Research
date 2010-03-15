ActionController::Routing::Routes.draw do |map|

  map.resources :groups

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.resources :users
  map.resource :session

  map.resources :researches do |researches|
    researches.resources :questionnaires, :collection => { :new => :post }
    researches.resources :items
  end

  # Route for admin research
  map.namespace :admin do |admin|
    admin.resources :researches, :collection => { :moderators => :get }, :member => { :role_management => :get,                    :new_member => :put, :edit_member => :put, :remove_member => :get } do |researches|
      researches.resources :items, :collection => {:reorder_items => :post, :reorder_pages => :post, :set_item_to_page => :post}
#      researches.resources :items do |items|
#        items.resources :item_values
#      end
      researches.resources :questions do |questions|
        questions.resources :item_values, :collection => {:reorder_item_values => :post }
      end
    end
  
    admin.resources :questions, :controller => 'items', :has_many => :item_values

    admin.resources :researches, :has_many => :moderators do |moderator|
      moderator.resources :moderators, :collection => { :attribute => :put }
    end
    admin.resources :roles
  end
 
  #Route for doc plugin
  map.resources :doc

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "researches"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
#  map.connect ':controller/:action/:id.:format'
end
