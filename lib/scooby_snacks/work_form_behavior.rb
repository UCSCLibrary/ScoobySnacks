module ScoobySnacks::WorkFormBehavior
  extend ActiveSupport::Concern  
  included do
    
    self.terms = []
    ScoobySnacks::METADATA_SCHEMA.display_field_names.each do |field_name|
      puts "TERM: #{field_name}"
      self.terms << field_name.to_sym
      delegate field_name.to_sym, to: :solr_document
    end

    self.required_fields = ScoobySnacks::METADATA_SCHEMA.required_field_names.map{|name| name.to_sym}
    
    def primary_terms 
      @primary_terms ||=  ScoobySnacks::METADATA_SCHEMA.primary_editor_field_names.map{|name| name.to_sym}
    end

    def secondary_terms 
      @primary_terms ||=  ScoobySnacks::METADATA_SCHEMA.secondary_editor_field_names.map{|name| name.to_sym}
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
