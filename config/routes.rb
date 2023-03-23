Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :static do
    collection do
      get :negotiated_rates_bulk_actions
    end
  end

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
      get :bulk_actions
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
