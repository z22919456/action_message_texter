Rails.application.routes.draw do
  mount ActionMessageTexter::Engine => '/action_message_texter'
end
