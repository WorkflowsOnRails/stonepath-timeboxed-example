StonepathExample::Application.routes.draw do
  devise_for :users

  authenticated :user, lambda {|u| u.role.reporter? } do
    root to: "issues#index", as: 'reporter_root'
  end

  authenticated :user, lambda {|u| u.role.deployer? } do
    root to: "issues#list_unscheduled", as: 'deployer_root'
  end

  authenticated :user, lambda {|u| u.role.developer? } do
    root to: "issues#list_assigned", as: 'developer_root'
  end

  devise_scope :user do
    root to: "devise/sessions#new", as: 'login_root'
  end

  resources :issues, only: [:index, :new, :create, :show] do
    resources :comments, only: [:create]
    member do
      post 'claim'
      post 'schedule_deployment'
      post 'sign_off'
    end
    collection do
      get 'list_pending'
      get 'list_assigned'
      get 'list_unscheduled'
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
