Callmom::Application.routes.draw do
  match 'call/call_ended' => 'call#call_ended'
  match 'call/logz' => 'call#logs'

  match 'test/call' => 'test#call'
  match 'test/create_dummy_log' => 'test#create_dummy_log'

  resources :call
  resources :grade
  resources :test

end
