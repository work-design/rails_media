Rails.application.routes.draw do

  namespace :cms, defaults: { business: 'cms' } do
    resources :videos do
      collection do
        get :list
        get :starred
      end
      member do
        patch :viewed
      end
    end
    resources :video_taxons
    resources :video_tags
    resources :audios, only: [:index]
    resources :carousels

    namespace :admin, defaults: { namespace: 'admin' } do
      resources :videos
      resources :audios
      resources :carousels
    end
  end

end
