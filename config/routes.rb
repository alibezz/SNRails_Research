ActionController::Routing::Routes.draw do |map|
  map.resources :questionnaires

  map.resources :groups

  map.resources :object_item_values


  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.resources :users
  map.resource :session

  map.resources :researches, :has_many => :items

  # Route for admin research
  map.namespace :admin do |admin|

    admin.resources :researches, :has_many => :items do |item|
     item.resources :items, :collection => {:reorder_items => :post, :reorder_pages => :post, :set_item_to_page => :post}
     item.resources :items, :questions, :has_many  => :item_values do |item_value|
       item_value.resources :item_values
     end
    end

    admin.resources :researches, :has_many => :questions do |question|
     question.resources :questions, :collection => {:reorder_questions => :post, :reorder_pages => :post, :set_question_to_page => :post}
     question.resources :questions, :questions, :has_many  => :item_values do |item_value|
       item_value.resources :item_values
     end
    end

    admin.resources :researches, :has_many => :moderators do |moderator|
     moderator.resources :moderators
    end
  end
 
  #Route for doc plugin
  map.resources :doc

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "researches"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
#  map.connect ':controller/:action/:id.:format'
end
