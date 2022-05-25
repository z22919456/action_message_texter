Rails.application.routes.draw do
  mount ActionTextMessenger::Engine => '/action_text_messenger'
end
