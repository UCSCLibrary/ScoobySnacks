#  NOTE
#  THIS GENERATOR IS NOT COMPLETE AND SHOULD NOT BE USED YET
#
require 'rails/generators'
class ScoobySnacks::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def copy_metadata_config
    copy_file "metadata.yml.example", "config/metadata.yml"
    directory "config/metadata"
    copy_file "metadata/shared.yml.example", "config/metadata/shared.yml"
  end

  def copy_edit_partials
    copy_file "views/_default.html.erb" "views/records/edit_fields/_default.html.erb"
    copy_file "views/_scalar.html.erb" "views/records/edit_fields/_scalar.html.erb"
    copy_file "views/_multi_controlled_vocabularies.html.erb" "views/records/edit_fields/_multi_controlled_vocabularies.html.erb"
  end

  def inject_mixins

    # in the form class for each work type, 
    # include ScoobySnacks::Forms::WorkFormBehavior
    #
    # in the presenter class for each work type, 
    # include 
    # add 
#    insert_into_file "app/forms/" do

    end
  end



end
