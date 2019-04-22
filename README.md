# ScoobySnacks

This gem allows administrators of a Hyrax application to define their metadata schema in a human readable configuration file (or files). The Hyrax application is configured automatically with the metadata properties defined in the configuration file when the application loads. This makes it easy to update the metadata schema details in one place, and implementing changes only requires restarting the application. 
Hopefully this approach will also make it easier to share metadata schema between institutions, and to write Samvera code that is independent of the details of a specific schema and is therefore more portable between institutions.

This project is currently designed on Hyrax 2.4. 

The documentation for this gem is currently outdated. Some major updates to both the gem and the documentation are expected in Spring 2019.

## Metadata Schema Configuration File & The M3 Project
The central goal of this gem is to define the metadata schema in a human readable configuration file. This includes all the attributes of each metadata property ("meta-metadata properties"). It is difficult to create a univerally functional and intuitive specification/format for this configuration file.  
The M3 project is working to address this issue by creating a shared metadata schema specification in collaboration with several institutions. We plan to use the resulting specification in future versions of ScoobySnacks.
ScoobySnacks currently uses its own type of YML metadata schema configuration file whose specification/format is not very well documented (although it is fairly intuitive). Thie schema meets UCSC's immediate needs, but it may require extension for other instituions application specific needs.

## The Name 'ScoobySnacks'

The name ScoobySnacks reflects the fact that this gem addresses a similar need to the ['dog-biscuits'](https://github.com/ULCC/dog_biscuits/wiki) gem, but takes a different approach. We plan to explore the possibility of merging the gems in the future, retaining the best aspects of each. 

## Installation

* First, install the gem by adding this line to your application's Gemfile:

```ruby
gem 'scooby_snacks'
```

And then execute:

    $ bundle

* Create a file called `config/initializers/metadata.rb` with the following contents:
```ruby
ScoobySnacks::METADATA_SCHEMA = ScoobySnacks::MetadataSchema.new
```

* In `app/controllers/catalog_controller.rb`, 
    * replace all `config.add_facet_field` lines related to your metadata schema with `ScoobySnacks::BlacklightConfiguration.add_facet_fields(config)`
    * replace all `config.add_index_field` lines related to your metadata schema with
`ScoobySnacks::BlacklightConfiguration.add_search_result_display_fields(config)`
    * replace all `config.add_show_field` lines related to your metadata schema with `ScoobySnacks::BlacklightConfiguration.add_show_fields(config)`
    * replace all `config.add_search_field` lines related to your metadata schema with `ScoobySnacks::BlacklightConfiguration.add_search_fields(config)`
    * replace all `config.add_sort_field` lines related to your metadata schema with `ScoobySnacks::BlacklightConfiguration.add_sort_fields(config)`

* In `app/models/solr_document.rb`, under the line `include Hyrax::SolrDocumentBehavior`, add the following:
```ruby
include ScoobySnacks::SolrDocumentBehavior
```

* The following three modifications need to be done for each of the work types you have defined in your application. Replace `WORK_TYPE` with the name of your work type, in lower case.
    * In `app/forms/hyrax/WORK_TYPE_form.rb`, under the line `class {WORK_TYPE}Form < Hyrax::Forms::WorkForm`, include the following: `include ScoobySnacks::WorkFormBehavior`
    * In `app/models/WORK_TYPE.rb`, comment out the line `include Hyrax::BasicMetadata` and add the folling underneath it: `include ScoobySnacks::WorkModelBehavior`

    * In `app/presenters/WORK_TYPE_show_presenter.rb` (or wherever you define your custom presenter classes), include the following: `include ScoobySnacks::PresenterBehavior`

