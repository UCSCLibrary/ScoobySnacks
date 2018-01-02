module ScoobySnacks::WorkFormBehavior
  extend ActiveSupport::Concern  
  included do
    
    work_type_attributes = ScoobySnacks::METADATA_SCHEMA['work_types'][self.model_class.to_s.downcase]

    self.terms = []
    work_type_attributes["display_terms"].each do |property_name|
      self.terms << property_name.to_sym
      delegate property_name.to_sym, to: :solr_document
    end

    self.required_fields = []
    work_type_attributes["required"].each do |property_name|
      self.required_fields << property_name.to_sym
    end  
    
    def primary_terms 
      return @primary_terms if !@primary_terms.nil?
      pt = []
      ScoobySnacks::METADATA_SCHEMA['work_types'][self.model_class.to_s.downcase]["primary"].each do |property_name|
        pt << property_name.to_sym
      end
      @primary_terms = pt
    end


  end
end
