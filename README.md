# ScoobySnacks

This gem is an attempt to allow administrators of Hyrax applications to define their entire metadata schema in a configuration file (or files). My hope is that this will encourage clear communication about metadata practices, help us share metadata profiles between institutions, and allow metadata librarians to control the application metadata schema without developer mediation. 

This project is currently designed on Hyrax 2.0. 

## The Metadata Schema in Configuration Files

The most important goal of this gem is to define the metadata schema entirely within a standardized set of configuration files, without hard coding any metadata information into the application itself. Defining standards for those metadata configuration files is a significant task that we should think about together if we want to use this approach.

Check out [this gem's wiki](https://github.com/UCSCLibrary/ScoobySnacks/wiki) for thoughts on how the metadata schema configuration files are formatted. We want feedback about how exactly this should work.

## The Name 'ScoobySnacks'

The name ScoobySnacks reflects the fact that this gem addresses a similar need to the ['dog-biscuits'](https://github.com/ULCC/dog_biscuits/wiki) gem, but takes a different approach. We plan to explore the possibility of merging the gems in the future, retaining the best aspects of each. 

## What works so far

This gem is not yet fully functional. We are sharing it now so that we can collaborate with our community on the gem's intended scope and on the details of how the metadata schema configuration files should look.
Most of this gem's core functionality works in a development environment, but not all. Metadata properties with arbitrary predicates, labels, and indexing rules can be defined in a configuration file, and a hyrax application can immediately create and save a work with those properties. Defining local authority classes with controlled vocabs and fancy autosuggest inputs needs some more work. The remaining development required is doable if there is enough interest in this approach to metadata handling. Test coverage is needed.

## Installation

First, install the gem by adding this line to your application's Gemfile:

```ruby
gem 'scooby_snacks'
```

And then execute:

    $ bundle

### Manual Installation
The install generator below is not yet working, so you need to edit files manually to integrate this code into your application. 

copy the view partials from this gem's install template into your application with a command similar to the following: 
```bash
cp ScoobySnacks/lib/generators/scooby_snacks/install/templates/views/* APPLICATION_ROOT/app/views/records/edit_fields/
```

create a file called `config/initializers/metadata.rb` with the following contents:
```ruby
require 'scooby_snacks/initialize'
```

In `app/models/solr_document.rb`, under the line `include Hyrax::SolrDocumentBehavior`, add the following:
```ruby
include ScoobySnacks::SolrDocumentBehavior
```

The following three modifications need to be done for each of the work types you have defined in your application. Replace `WORK_TYPE` with the name of your work type, in lower case.
In `app/forms/hyrax/WORK_TYPE_form.rb`,
under the line `class {WORK_TYPE}Form < Hyrax::Forms::WorkForm`, include the following:
```ruby
include ScoobySnacks::WorkFormBehavior
```
In `app/models/WORK_TYPE.rb`, comment out the line `include Hyrax::BasicMetadata` and add the folling underneath it:
```ruby
#include Hyrax::BasicMetadata
include ScoobySnacks::WorkModelBehavior
```

In `app/presenters/WORK_TYPE_show_presenter.rb` (or wherever you define your custom presenter classes), include the following:
```ruby
include ScoobySnacks::PresenterBehavior
```

### Install Generator

I started on a generator to automate installation of this gem. It is not finished yet, and should probably wait until there is more consensus on what the gem is supposed to do and who wants to use it. 
The generator would replace the steps above which modify application files. Instead, one would just run:

    $ bundle exec rake scooby_snacks:install

But don't try it now, it won't work.
