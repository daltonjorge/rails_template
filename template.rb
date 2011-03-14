run "rm public/index.html"

initializer 'generators.rb', <<-RUBY
Rails.application.config.generators do |g|
  g.test_framework = :rspec
end
RUBY

gem "devise"
gem "cancan"
gem "jquery-rails"
gem "will_paginate", "~> 3.0.pre2"
gem 'rspec-rails', :group => [:development, :test]
gem 'capybara', :git => 'git://github.com/jnicklas/capybara.git', :group => [:development, :test]

run "bundle install"

generate "rspec:install"
generate "devise:install"
generate 'devise user username:string'
generate "devise:views"
generate "jquery:install"

gsub_file "app/models/user.rb", "attr_accessible :email", "attr_accessible :username, :email"
gsub_file "config/database.yml", /username:(.)*/, "username: postgres"
gsub_file "config/database.yml", /password:(.)*/ do
  
<<-RUBY
password: postgres
  host: localhost
  port: 5432
RUBY
end

rake "db:drop:all"
rake "db:create"
rake "db:migrate"

append_file "db/seeds.rb", %(\nUser.create(:username => 'admin', :email => 'admin@mail.com', :password => 'password', :password_confirmation => 'password'))

rake "db:seed"

gsub_file "config/initializers/devise.rb", /# config.authentication_keys = \[ :email \]/, 'config.authentication_keys = [ :username ]'

generate :controller, "home", "index"
route %(root :to => "home#index")

inject_into_file "app/controllers/home_controller.rb", :after => "class HomeController < ApplicationController\n" do
  "  before_filter :authenticate_user!\n\n"
end
