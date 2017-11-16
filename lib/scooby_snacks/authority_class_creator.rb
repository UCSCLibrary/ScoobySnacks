module ScoobySnacks::AuthorityClassCreator

  schema = ScoobySnacks::METADATA_SCHEMA

  default_property = schema["properties"]["default"]
  default_property ||= {}
  schema["classes"] ||= {}
  schema["classes"]["default"] ||= {}
  default_class_attributes = schema["classes"]["default"]

  #  Loop through classes defined in metadata
  schema["classes"].except("default").each do |class_name, class_attributes|
    # merge in default class attributes if any
    # TODO THIS SHOULD HAPPEN IN INITIALIZER
    class_attributes = default_class_attributes.deep_merge(class_attributes)
    properties = class_attributes["properties"]
    properties ||= {}

    #create the new class
    new_class = Class.new(ActiveTriples::Resource) do

      configure rdf_label: class_attributes["rdf_label"]

      #loop through the class properties
      properties.each do |property_name, prop|
        next if prop.nil?
        #merge in default property settings
        # TODO THIS SHOULD HAPPEN IN INITIALIZER
        prop = default_property.deep_merge(prop) unless default_property.nil?
        #define the property
        property property_name.parameterize.underscore.to_sym, predicate: ::RDF::URI.new(prop["predicate"]), multiple: (prop["multiple"].to_s == "true")
      end

      def solrize      # Return a tuple of url & label
        return [rdf_subject.to_s] if rdf_label.first.to_s.blank? || rdf_label.first.to_s == rdf_subject.to_s
        [rdf_subject.to_s, { label: "#{rdf_label.first}$#{rdf_subject}" }]
      end
    end

    # This names the class and makes it accessible to the application
    Ucsc::ControlledVocabularies.const_set(class_name, new_class)
  end

end

