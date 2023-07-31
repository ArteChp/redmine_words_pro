if Rails.env.development?
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
post '/check_files', :to => 'repo_words#check_files', as: :check_files
