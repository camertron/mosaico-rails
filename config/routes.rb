Mosaico::Engine.routes.draw do
  resources :projects, only: [:create, :show, :update]
  get '/projects/:template_name/new', to: 'projects#new'

  resources :templates, param: :template_name, only: [:show]

  scope :images, as: :mosaico_image do
    get '/(:id)', to: 'images#show'
    post '/', to: 'images#create'
    delete '/:id', to: 'images#destroy'
  end
end
