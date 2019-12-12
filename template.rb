# encoding: utf-8

##############
## Includes ##
##############

# Remove tmp folder after completing
require 'fileutils'
# Escape shell commands
require 'shellwords'
# PrettyPrint
require 'pp'

# REMOVE WHEN DONE DEBUGGING
# Interactive console
require 'byebug'

###############
## Constants ##
###############

RAILS_REQUIREMENT = '~> 6.0.0'.freeze
RAILS_TEMPLATE_REPO = 'https://github.com/athix/rails-template.git'.freeze
NODE_VERSION = '13.0.1'.freeze

###########################
## Define Template Logic ##
###########################

def apply_template!
  ###########################
  ## Ensure Valid Settings ##
  ###########################

  assert_minimum_rails_version!
  assert_valid_options!

  ########################
  ## Load Default Files ##
  ########################

  add_template_files_to_tmp_path

  ####################################
  ## Asking the important questions ##
  ####################################

  puts "\n\nTime for some questions...\n\n"

  git_repo_url

  puts "\nQuestions complete, this may take a moment...\n\n"

  ########################
  ## Copy Default Files ##
  ########################

  template 'Gemfile.tt', force: true
  template 'README.md.tt', force: true
  template 'ruby-gemset.tt', '.ruby-gemset'
  template 'ruby-version.tt', '.ruby-version', force: true
  template 'nvmrc.tt', '.nvmrc', force: true
  template 'Dockerfile.tt'
  template 'docker-compose.yml.tt'
  template 'env.tt', '.env'

  copy_file 'editorconfig', '.editorconfig'
  copy_file 'gitignore', '.gitignore', force: true
  copy_file 'simplecov', '.simplecov'
  copy_file 'dockerignore', '.dockerignore'

  apply 'app/template.rb'
  apply 'config/template.rb'

  ########################################
  ## Runs after bundle and yarn install ##
  ########################################

  after_bundle do
    copy_file 'config/webpacker.yml', force: true # Copy after webpacker bundles
    # Generate Default Landing Page
    generate :controller, 'LandingPages', 'home'
    route "root to: 'landing_pages#home'"
    # Run install scripts
    generate 'rspec:install'
    generate 'pundit:install'
    generate 'sorcery:install'
    # Generate schema.rb
    rails_command 'db:create'
    rails_command 'db:migrate'
    # Prep git repo
    add_git_commit_and_origin_remote! unless any_local_git_commits?
  end
end

def assert_minimum_rails_version!
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  raise Rails::Generators::Error,
    "This template requires Rails #{RAILS_REQUIREMENT}. You are using "\
    "#{rails_version}."
end

def assert_valid_options!
  required_options = [:database, :skip_test, :webpack]
  valid_options = {
    database: 'postgresql',
    skip_bundle: false,
    skip_gemfile: false,
    skip_git: false,
    skip_test: true,
    webpack: 'vue',
    edge: false
  }
  valid_options.each do |key, expected|
    # Skip if not required and not included
    unless required_options.include?(key)
      next unless options.key?(key)
    end
    actual = options[key]
    unless actual == expected
      raise Rails::Generators::Error,
        "Unsupported option: #{key}=#{actual.present? ? actual : 'nil'} - "\
        "Expected: #{key}=#{expected}"
    end
  end
end

# Add template directory to source_paths so that Thor can resolve actions like
# `copy_file` and `template` regardless of if invoked locally or remotely via
# HTTPS. If files are not present, clone them to a local tmp directory.
def add_template_files_to_tmp_path
  if __FILE__ =~ %r{\Ahttps:\/\/}
    require 'tmpdir'
    source_paths.unshift(tempdir = Dir.mktmpdir('rails-template-'))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      '--quiet',
      RAILS_TEMPLATE_REPO,
      tempdir
    ].map(&:shellescape).join(' ')

    # Fetch and checkout branch name from filepath
    if (branch = __FILE__[%r{rails-template/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  elsif __FILE__ =~ %r{\Ahttp:\/\/}
    raise Rails::Generators::Error,
      'Please use HTTPS instead of HTTP for fetching this script!'
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def gemfile_requirement(name)
  @original_gemfile ||= IO.read("Gemfile")
  req = @original_gemfile[/gem\s+['"]#{name}['"]\s*(,[><~= \t\d\.\w'"]*)?.*$/, 1]
  req && req.gsub("'", %(")).strip.sub(/^,\s*"/, ', "')
end

def git_repo_url
  @git_repo_url ||=
    ask_with_default('What is the git remote URL for this project?', 'skip')
end

def ask_with_default(question, default)
  question = (question.split('?') << " [#{default}]?").join
  answer = ask(question, :cyan)
  answer.to_s.strip.present? ? answer : default
end

def any_local_git_commits?
  system('git log > /dev/null 2>&1')
end

def git_repo_specified?
  git_repo_url != 'skip' && git_repo_url.strip.present?
end

def add_git_commit_and_origin_remote!
  git add: '-A .'
  project_options = options.except('ruby', 'template').pretty_inspect
  git commit:
    "-n -m 'Initial Commit' "\
    "-m 'Project generated with the following options:\n\n#{project_options}' "\
    "-m 'Using the template found at:\n\n#{RAILS_TEMPLATE_REPO}'"
  git remote: "add origin #{git_repo_url.shellescape}" if git_repo_specified?
end

############################
## Execute Template Logic ##
############################

apply_template!
