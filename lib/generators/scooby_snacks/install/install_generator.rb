#  NOTE
#  THIS GENERATOR IS NOT COMPLETE AND SHOULD NOT BE USED YET
#
require 'rails/generators'
class ScoobySnacks::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def copy_metadata_config
    # This defines a simple generic metadata schema 
    # nearly equivalent to the Hyrax basic metadata
    copy_file "metadata.yml", "config/metadata.yml"
  end

  def copy_view_partials
    # Using Scooby Snacks, we do not customize view partials
    # using files named based on the property being customized.
    # Instead, we name view partials after 'input types',
    # and assign these input types to properties. 
    # Here we define two view input types by default. 
    copy_file "views/_default.html.erb" "views/records/edit_fields/_default.html.erb"
    copy_file "views/_scalar.html.erb" "views/records/edit_fields/_scalar.html.erb"
    copy_file "views/_controlled_vocabularies.html.erb" "views/records/edit_fields/_multi_controlled_vocabularies.html.erb"
  end

  def copy_metadata_config
    # This defines a simple generic metadata schema 
    # nearly equivalent to the Hyrax basic metadata
    copy_file "metadata.yml", "config/metadata.yml"
  end

  def inject_mixins

    # in the Hyrax intializer, 
    # require the scoobysnacks initializer script
    insert_into_file "config/initializers/hyrax.rb", :after => "do |config|" do 
      %{\n # Injected via scooby_snacks:install \n require 'scooby_snacks/initialize' \n}
    #
    # in the form class for each work type, 
    # include ScoobySnacks::WorkFormBehavior
    #
    # in the model class for each work type, 
    # include ScoobySnacks::WorkModelBehavior
    #
    # in the presenter class for each work type, 
    # include ScoobySnacks::PresenterBehavior
    #
    # in the SolrDocument class,
    # include ScoobySnacks::SolrBehavior

    end
  end



end
