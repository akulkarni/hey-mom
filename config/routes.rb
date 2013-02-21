Callmom::Application.routes.draw do
  match 'mom/call_ended' => 'mom#call_ended'
  match 'mom/logz' => 'mom#logs'

  match 'test/call' => 'test#call'
  match 'test/create_dummy_log' => 'test#create_dummy_log'

  resources :mom
  resources :grade
  resources :test

end
