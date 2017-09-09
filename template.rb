# Add the current directory to the path Thor uses
# to look up files

def source_paths
  Array(super) + [File.expand_path(File.dirname(__FILE__))]
end

# Create .ruby-version and set default version of Ruby to use

create_file '.ruby-version' do <<-RUBYVERSION
ruby-2.4.1
RUBYVERSION
end

# Create .ruby-gemset and set Gemset name based on the application's name

create_file '.ruby-gemset' do <<-RUBYGEMSET
#{app_name}
RUBYGEMSET
end

# Remove the default Gemfile and replace the with GEMFILE heredoc

remove_file 'Gemfile'
create_file 'Gemfile' do <<-GEMFILE
source 'https://rubygems.org'
ruby '2.4.1'
# ruby-gemset=#{app_name}

git_source(:github) do |repo_name|
  repo_name = "\#{repo_name}/\#{repo_name}" unless repo_name.include?('/')
  "https://github.com/\#{repo_name}.git"
end

# Rails

gem 'rails', '5.1.4'

# Default Rails gems

gem 'coffee-rails', '4.2.2'
gem 'jbuilder',     '2.7.0'
gem 'sass-rails',   '5.0.6'
gem 'turbolinks',   '5.0.1'
gem 'uglifier',     '3.2.0'

# Project specific gems

gem 'autoprefixer-rails',       '7.1.4'
gem 'bcrypt',                   '3.1.11'
gem 'bootstrap-sass',           '3.3.7'
gem 'font-awesome-rails',       '4.7.0.2'
gem 'high_voltage',             '3.0.0'
gem 'jquery-rails',             '4.3.1'
gem 'kaminari',                 '1.0.1'

# Development & testing specific gems

group :development, :test do
  gem 'better_errors',      '2.3.0'
  gem 'binding_of_caller',  '0.7.2'
  gem 'byebug',             '9.1.0', platforms: [:mri, :mingw, :x64_mingw]
  gem 'faker',              '1.8.4'
  gem 'sqlite3',            '1.3.13'
end

group :test do
  gem 'minitest-reporters',         '1.1.18'
  gem 'rails-controller-testing',   '1.0.2'
end

# Production gems

group :production do
  gem 'passenger',  '5.1.8'
  gem 'pg',         '0.21.0'
end
GEMFILE
end

# Copy (and in some cases remove default) dot files, license and Procfile

copy_file 'dotfiles/.codeclimate.yml', '.codeclimate.yml'
remove_file '.gitignore'
copy_file 'dotfiles/.gitignore', '.gitignore'
copy_file 'dotfiles/.rubocop.yml', '.rubocop.yml'
copy_file 'dotfiles/.scss-lint.yml', '.scss-lint.yml'
copy_file 'dotfiles/circle.yml', 'circle.yml'
copy_file 'dotfiles/LICENSE', 'LICENSE'
copy_file 'dotfiles/Procfile', 'Procfile'

# Replace default application.js and application.css with updated
# application.js and application.scss, copy default styles.scss

remove_file 'app/assets/javascripts/application.js'
copy_file 'assets/application.js', 'app/assets/javascripts/application.js'

remove_file 'app/assets/stylesheets/application.css'
copy_file 'assets/application.scss', 'app/assets/stylesheets/application.scss'
copy_file 'assets/styles.scss', 'app/assets/stylesheets/styles.scss'

# Copy default controllers

copy_file 'controllers/account_activations_controller.rb', 'app/controllers/account_activations_controller.rb'
remove_file 'app/controllers/application_controller.rb'
copy_file 'controllers/application_controller.rb', 'app/controllers/application_controller.rb'
copy_file 'controllers/password_resets_controller.rb', 'app/controllers/password_resets_controller.rb'
copy_file 'controllers/sessions_controller.rb', 'app/controllers/sessions_controller.rb'
copy_file 'controllers/users_controller.rb', 'app/controllers/users_controller.rb'

# Copy default helpers

remove_file 'app/helpers/application_helper.rb'
copy_file 'helpers/application_helper.rb', 'app/helpers/application_helper.rb'
copy_file 'helpers/sessions_helper.rb', 'app/helpers/sessions_helper.rb'
copy_file 'helpers/users_helper.rb', 'app/helpers/users_helper.rb'

# Remove jobs folder

remove_dir 'app/jobs'

# Copy default mailers

remove_file 'app/mailers/application_mailer.rb'
copy_file 'mailers/application_mailer.rb', 'app/mailers/application_mailer.rb'
copy_file 'mailers/user_mailer.rb', 'app/mailers/user_mailer.rb'

# Copy default views

remove_dir 'app/views/layouts'
directory 'views/kaminari', 'app/views/kaminari'
directory 'views/layouts', 'app/views/layouts'
directory 'views/pages', 'app/views/pages'
directory 'views/password_resets', 'app/views/password_resets'
directory 'views/sessions', 'app/views/sessions'
directory 'views/shared', 'app/views/shared'
directory 'views/user_mailer', 'app/views/user_mailer'
directory 'views/users', 'app/views/users'

# Copy default config/environment files

remove_dir 'config/environments'
directory 'config_files/environments', 'config/environments'

# Copy default config/initializer files

remove_dir 'config/initializers'
directory 'config_files/initializers', 'config/initializers'

# Copy default locale file

remove_file 'config/locales/en.yml'
copy_file 'config_files/locales/en.yml', 'config/locales/en.yml'

# Copy default routes file

remove_file 'config/routes.rb'
copy_file 'config_files/routes.rb', 'config/routes.rb'

# Create new secrets.yml with email_provider_username and email_provider_password
# for use with Sendgrid

require 'securerandom'

remove_file 'config/secrets.yml'
create_file 'config/secrets.yml', <<-SECRETS
development:
  email_provider_username: <%= ENV["SENGRID_USERNAME"] %>
  email_provider_password: <%= ENV["SENDGRID_PASSWORD"] %>
  secret_key_base: #{SecureRandom.hex(64)}

test:
  secret_key_base: #{SecureRandom.hex(64)}

# Do not keep production secrets in the repository,
# instead read values from the environment.

production:
  email_provider_username: <%= ENV["SENDGRID_USERNAME"] %>
  email_provider_password: <%= ENV["SENDGRID_PASSWORD"] %>
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
SECRETS

# Tidy up config/application.rb

comment_lines 'config/application.rb', /active_job/
gsub_file 'config/application.rb', /"/, '\''

# Run bundle install without production gems

run 'bundle install --without production'

# Generate User model

generate(:model, 'User', 'email:string:index')
generate(:migration, 'AddFieldsToUsers', 'password_digest:string', 'remember_digest:string', 'activation_digest:string', 'activated:boolean', 'activated_at:datetime', 'reset_digest:string', 'reset_sent_at:datetime', 'admin:boolean')

# Run migrations

rails_command 'db:migrate'

# Replace generated user model with default user model

remove_file 'app/models/user.rb'
copy_file 'models/user.rb', 'app/models/user.rb'

# Copy default test files

remove_dir 'test'
directory 'test_files', 'test'

# Initial commit, track all files not ignored by .gitignore, and commit

git add: '.'
git commit: '-a -m "Initial commit"'
