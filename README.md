# Rails Application Template

Rails Guides Documentation: [Rails Application Templates](https://guides.rubyonrails.org/rails_application_templates.html)

Used the following as reference: [Ackama Rails Template](https://github.com/ackama/rails-template)

## Requirements

* Rails `~> 6.0`
* Yarn
* PostgreSQL

## Usage

**New Applications:**

```text
rails new <application_name> \
  -d postgresql \
  -T \
  --webpack=vue \
  -m https://raw.githubusercontent.com/athix/rails-template/master/template.rb
```

## Installation

To make this the default Rails application template on your system, create a `~/.railsrc` file with the following:

```text
-d postgresql
-T
--webpack=vue
-m https://raw.githubusercontent.com/athix/rails-template/master/template.rb
```
