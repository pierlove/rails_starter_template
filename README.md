# Rails Application Template

Yet another opinionated Rails starter template, designed to get you up and running in no time. Pre-configured to allow CI integration with CircleCI, auto-deployment to Heroku, and quality metrics by Code Climate.

## Usage

Download or clone this repository to your projects folder (or wherever you want to save, be sure to remember where you save the template files as they need to be referenced when you create your Rails application in the next steps)

`cd ~/Projects`

`git clone git@github.com:professorNim/rails_starter_template.git`

If using rvm or rbenv, create a new gemset. If you saved/cloned the template files into the same directory that you will be creating your new Rails application, run the following. Otherwise reference the location used to save/clone the template into in the `rails new` command. Don't worry about including `--skip-bundle` as an option, bundler will be run as part of the template.

`rails new mynewappname --skip-bundle -m ./rails_starter_template/template.rb`

Search your new Rails application for `# TO DO` to find items you should replace and/or fill in with your own data.

That's it!

## Application Specific Gems

- autoprefixer-rails
- bcrypt
- bootstrap-sass
- font-awesome-rails
- high_voltage
- jquery-rails
- kaminari

## Development & testing gems

- better_errors
- binding-of-caller
- byebug
- faker
- sqlite3
- minitest-reporters
- rails-controller-testing

## Production gems

- passenger
- pg
