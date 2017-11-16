# ScoobySnacks

This gem is a first attempt to allow Hyrax applications to define their entire metadata profile in a configuration file. This allows metadata librarians to make changes to the metadata schema and indexing rules without developer assitance. 

The name ScoobySnacks reflects the fact that this gem addresses a similar need to the 'dog-biscuits' gem, but takes a different approach. We plan to explore the possibility of merging the gems in the future, retaining the best aspects of each. 

This project is currently designed for Hyrax 1. Hyrax 2 branch is planned. 


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scooby_snacks'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scooby_snacks

Then modify the following files:

In `app/forms/WORK_TYPE_form.rb`,
```ruby
include ScoobySnacks::WorkFormBehavior
```

In `app/models/WORK_TYPE.rb`,
```ruby
include ScoobySnacks::WorkModelBehavior
```

In `app/models/solr_document.rb`,
```ruby
include ScoobySnacks::SolrDocumentBehavior
```

In `app/presenters/WORK_TYPE_presenter.rb`,
```ruby
include ScoobySnacks::PresenterBehavior
```


