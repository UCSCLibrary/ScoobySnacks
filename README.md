# ScoobySnacks

This gem is an attempt to allow administrators of Hyrax applications to define their entire metadata schema in a configuration file (or files). We hope that this will encourage clear communication about metadata practices, help share metadata profiles between institutions, and allow metadata librarians to control the application metadata schema without developer assitance. 

This project is currently designed on Hyrax 1. Hyrax 2 branch shouldn't be too hard if there is interest.

## What works so far

This gem is not yet fully functional. We are sharing it now so that we can collaborate with our community on the gem's intended scope and on the details of how the metadata schema configuration files should look.
Most of this gem's core functionality works in a development environment, but not all. Metadata properties with arbitrary predicates, labels, and indexing rules can be defined in a configuration file, and a hyrax application can immediately create and save a work with those properties. Defining local authority classes with controlled vocabs and fancy autosuggest inputs needs some more work. The remaining development required is doable if there is enough interest in this approach to metadata handling. Test coverage is needed.

## The Name 'ScoobySnacks'

The name ScoobySnacks reflects the fact that this gem addresses a similar need to the 'dog-biscuits' gem, but takes a different approach. We plan to explore the possibility of merging the gems in the future, retaining the best aspects of each. 


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