module ScoobySnacks::WorkFormBehavior
  extend ActiveSupport::Concern  
  included do
    
    work_type_attributes = ScoobySnacks::METADATA_SCHEMA['work_types'][self.model_class.to_s.downcase]

    self.terms = [:title]
    work_type_attributes["display_terms"].each do |property_name|
      puts "adding display term #{property_name.to_sym}"
      self.terms << property_name.to_sym
    end

    self.required_fields = [:title]
    work_type_attributes["required"].each do |property_name|
      puts "adding required #{property_name.to_sym}"
      self.required_fields << property_name.to_sym
    end  
    
    def primary_terms 
      pt = [:title]
      ScoobySnacks::METADATA_SCHEMA['work_types'][self.model_class.to_s.downcase]["primary"].each do |property_name|
        pt << property_name.to_sym
      end
      pt
    end
  end
end
