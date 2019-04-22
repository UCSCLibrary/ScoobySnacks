module ScoobySnacks::WorkFormBehavior
  extend ActiveSupport::Concern  
  included do

    self.terms = []
    ScoobySnacks::METADATA_SCHEMA.fields.keys.each do |field_name|
      self.terms << field_name.to_sym
#      delegate field_name.to_sym, to: :solr_document
      delegate field_name.to_sym, to: :model
    end

    self.required_fields = ScoobySnacks::METADATA_SCHEMA.required_field_names.map{|name| name.to_sym}

    def schema
      ScoobySnacks::METADATA_SCHEMA
    end
    
    def primary_terms 
      @primary_terms ||=  (schema.primary_display_field_names + schema.editor_primary_display_field_names).uniq.map{|name| name.to_sym}
    end

    def secondary_terms 
      @secondary_terms ||=  (schema.all_field_names - schema.primary_display_field_names - schema.editor_primary_display_field_names).map{|name| name.to_sym}
    end

    def self.build_permitted_params
      permitted = super
      ScoobySnacks::METADATA_SCHEMA.controlled_field_names.each do |field_name|
        permitted << {"#{field_name}_attributes".to_sym => [:id, :_destroy]}
      end
      return params
    end


  end
end
