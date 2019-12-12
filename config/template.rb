environment <<~CODE
##################################
## Configure Generator Defaults ##
##################################

config.generators do |g|
  g.template_engine :slim
  g.test_framework :rspec
  g.fixture_replacement :factory_bot
  g.helper = false
  g.assets = false
  g.view_specs = false
  g.controller_specs = false
  g.skip_routes = true
end
CODE

environment 'config.i18n.fallbacks = [:en]'
environment 'config.sass.preferred_syntax = :sass'

template 'config/locales/en.yml.tt', force: true
template 'config/database.yml.tt', force: true
