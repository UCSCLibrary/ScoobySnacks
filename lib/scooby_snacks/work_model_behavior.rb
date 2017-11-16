module ScoobySnacks::WorkModelBehavior
  # A model mixin to define metadata 
  # properties and options based on
  # the schema configuration files
  extend ActiveSupport::Concern

  included do
    
    id_blank = proc { |attributes| attributes[:id].blank? }
    class_attribute :controlled_properties
    class_attribute :multi_controlled_properties
    class_attribute :all_controlled_properties
    self.controlled_properties = []
    self.all_controlled_properties = []
    self.multi_controlled_properties = {}
    
    ScoobySnacks::METADATA_SCHEMA['work_types'][self.human_readable_type.downcase]["properties"].each do |prop_name, prop|
      
      index_work_as = :stored_searchable
      index_work_as = prop['index']['index_as'] if prop.key? prop['index']
      is_multiple = prop['multiple'].to_s == "true" ||  prop['multiple'].blank?
      
      if(ns = prop['rdf_namespace'])
        predicate = "::RDF::Vocab::#{ns}".constantize.send prop['predicate']
      elsif prop['predicate'].include?("http")
        predicate = ::RDF::URI.new prop['predicate']
      else
        raise ArgumentError.new("invalid predicate definition")
      end
      
      property_args = {predicate: predicate, multiple: is_multiple}
      property_args[:class_name] = prop['class'] unless prop['class'].nil?

      # define the property and its indexing
      # unless it is already defined (e.g. in hyrax core)
      unless respond_to? prop_name.to_sym
        property prop_name.to_sym, property_args  do |index| 
          index.as index_work_as
        end
      end
      
      # define controlled vocabularies
      case prop['input'] 
      when 'controlled'
        self.controlled_properties << prop_name
        self.all_controlled_properties << prop_name
      when 'multi_controlled'
        self.multi_controlled_properties << prop_name
        self.all_controlled_properties << prop_name
      end
      
      #         define nested attributes (blank nodes)
      if prop['range'] && prop['range'].include?("Class:")
        accepts_nested_attributes_for prop_name.to_sym, reject_if: id_blank, allow_destroy: true
      end
      
    end

    # used by Hyrax, I think
    # (taken from Hyrax::BasicMetadata)
    # I'm not sure whether/how the scholarsphere stuff is used
    property :label, predicate: ActiveFedora::RDF::Fcrepo::Model.downloadFilename, multiple: false
    #
    property :relative_path, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#relativePath'), multiple: false
    property :import_url, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#importUrl'), multiple: false
    
  end
end

