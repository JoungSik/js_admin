JSAdmin::Engine.routes.draw do
  root to: "models#index"

  get "/:model_id", to: "resources#index", as: :resources
  get "/:model_id/new", to: "resources#new", as: :new_resource
  post "/:model_id", to: "resources#create"
  get "/:model_id/:id", to: "resources#show", as: :resource
  get "/:model_id/:id/edit", to: "resources#edit", as: :edit_resource
  patch "/:model_id/:id", to: "resources#update"
  put "/:model_id/:id", to: "resources#update"
  delete "/:model_id/:id", to: "resources#destroy"
end
