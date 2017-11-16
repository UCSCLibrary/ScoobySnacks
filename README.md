# ScoobySnacks

This gem is an attempt to allow administrators of Hyrax applications to define their entire metadata schema in a configuration file (or files). We hope that this will encourage clear communication about metadata practices, help share metadata profiles between institutions, and allow metadata librarians to control the application metadata schema without developer assitance. 

The name ScoobySnacks reflects the fact that this gem addresses a similar need to the 'dog-biscuits' gem, but takes a different approach. We plan to explore the possibility of merging the gems in the future, retaining the best aspects of each. 

This project is currently designed for Hyrax 1. Hyrax 2 branch is planned. 

## Installation

First, install the gem by adding this line to your application's Gemfile:

```ruby
gem 'scooby_snacks'
```

And then execute:

    $ bundle

Then run the gem's install scripts to modify your application files to load the metadata schema from configuration files.

    $ bundle exec rake scooby_snacks:install

## Configuring the Metadata Schema

Check out this gem's wiki for thoughts on how the metadata schema configuration files are formatted. We want feedback about how exactly this should work.