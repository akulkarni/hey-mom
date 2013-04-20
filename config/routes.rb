Callmom::Application.routes.draw do
  match 'call/call_ended' => 'call#call_ended'
  match 'call/logz' => 'call#logs'

  match 'test/call' => 'test#call'
  match 'test/create_dummy_log' => 'test#create_dummy_log'

  match 'grade/:user' => 'grade#index'

  match '/register' => 'register#create'

  resources :call
  resources :grade
  resources :test
  resources :register

end
