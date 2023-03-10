Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get '/providers', to: 'providers#index', as: "providers_path"
  get '/providers/new', to: 'providers#new', as: "new_provider_path"
  post '/providers', to: 'providers#create'
  get '/providers/:id', to: 'providers#show', as: "provider_path"
  get '/providers/:id/edit', to: 'providers#edit', as: "edit_provider_path"
  put '/providers/:id', to: 'providers#update'
  patch '/providers/:id', to: 'providers#update'
  delete '/providers/:id', to: 'providers#destroy'

  post '/providers/import', to: 'providers#import'

  resources :facilities do
    collection do
      post :import
      post :bulk_delete
      post :bulk_import
    end
  end

  resources :services do
    collection do
      post :import
      post :bulk_delete
    end
  end

  resources :ratings do
    collection do
      post :import
      post :bulk_delete
    end
  end

  resources :codes do
    collection do
      post :import
      post :bulk_delete
      post :bulk_update
    end
  end


  resources :health_plan_networks do
    collection do
      post :import
      post :bulk_delete
    end
  end

  resources :negotiated_rates do
    collection do
      post :import
      post :bulk_delete
      post :bulk_import
    end
  end

  resources :clinicians do
    collection do
      post :import
      post :bulk_delete
      post :bulk_import
    end
  end

  resources :utilizations do
    collection do
      post :import
      post :bulk_delete
    end
  end

  resources :timely_and_effective_care_ratings do
    collection do
      post :import
      post :bulk_delete
    end
  end

  resources :organizations do
    collection do
      post :import
      post :bulk_delete
    end
  end

end
