Callmom::Application.routes.draw do
  match 'mom/call' => 'mom#call'
  match 'mom/call_ended' => 'mom#call_ended'
  match 'mom/logz' => 'mom#logs'
  match 'mom/grade' => 'mom#grade'
  resources :mom

end
