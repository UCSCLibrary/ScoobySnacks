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





## Usage

I have started writing generators to do this instal

## Development Plans

If we decide to invest more in this gem, three directions of development seem reasonable.

### Hyrax 2

The current gem is based on Hyrax 1. We should create a Hyrax 2 fork in anticipation of upgrading (ucsc plans to start trying out this upgrade relatively soon). This should not require major refactoring, but may require some attention and subtle adjustments. 

### Dog Biscuits 

Dog Biscuits is another Hyrax gem designed to get at a similar problem. I need to look more closely at what it does and does not do, but it seems to have some good features to facilitate the sharing of metadata that we should take advantage of. However, it still relies on generating biolerplate code to implement the schema. We really want our configuration file to directly control the current metadata schema that is loaded in the system, which is what this gem accomplishes. We should look into how we can merge the best aspects of both gems. 

### Automatic documentation creation

Several people have suggested that the same machine-readable configuration files that define the metadata schema should be used to auto-generate human-readable documentation about that schema (so that the documentation must always reflect the actual schema). I know of some systems for automatically generating documentation from code that has specially formatted comments, but have not used any extensively enough to have an opinion on how best to do this. Thoughts?

### Work Types

Currently this code assumes that you have already defined the work types you need using the standard Hyrax work generator.

It would be possible, but somewhat more ambitious, to add the ability to define work types in configuration files in the same way that we define metadata there. This would be convenient for several reasons, and would make setting up a Hyrax application easier, and would save us a lot of boilerplate code.

I need to learn a littel more to make sure this can be done at all with any big technical headaches. Even if it is relatively easy to accomplish, I am ambivalent about whether we should (though it is very tempting to me). It is unclear whether definitions of work types in Hyrax should be part of the metadata schema or the application. 
Also, I am concerned that making this change would intimidate potential adopters of this gem, who might want to share metadata schemas but remain understandably hesitant about refactoring their potentially complex work type code. It may be possible to make this feature optional down the line, if we end up using this gem or an offshoot of it.  

My instinct is that it would not be very daunting to write code that generates work type classes and all their boilerplate code dynamically based on the metadata schema from the configuration files (so that you would never have to run the hyrax work type generator). Of course, work types are more than bundles of metadata predicates; they often have custom functionality attached. The work type classes that are dynamically created based on the configuration file could be set to load optional customization code, so that it developers could extend these classes by creating mixins in their application based on the work type. 
For example, instead of adding code to the "GenericWork" class defined in 'models/generic_work.rb', we would create a file called 'models/generic_work_behavior.rb'. Then if the configuration file defines a work type called GenericWork, we can expect the application to look for and load this file when it creates the GenericWork class. Same thing for forms, presenters, etc. Users could also specify other mixins to include in these classes using options in the configuration file (e.g. when defining a AudioWork, one could specify "lib/MyApp/time_based_functions.rb" as an extra mixing to load).

This would be great for people starting from a brand new hyrax install, but that isn't most of us. We would need to make it relatively easy to refactor existing work type code (of arbitrary complexity) into this new format, or to make it possible to disable this feature easily.

Thoughts welcome!

## My draft of the actual format/specification
## Contributing

Development help is always welcome, but the immediate focus should be on the metadata specification itself. How do you want your metadata schema to look? What would be most intuitive to read? What would make it easy to make changes?

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
