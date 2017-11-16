# This local variable hash will become our metadata schema constant
schema = {}

# Load each of the metadata extensions
# These files should not overlap, as there is no guarantee which will take precendence
metadata_extension_dir = "#{Rails.root.to_s}/config/metadata/"
Dir.foreach(metadata_extension_dir) do |item|
  next if item == '.' or item == '..'
  new_file = YAML.load_file(metadata_extension_dir + item)
  schema = schema.deep_merge(new_file) if new_file
end

# Load primary metadata file (this file take precendence over all others)
metadata_config = YAML.load_file("#{Rails.root.to_s}/config/metadata.yml")
schema =  schema.deep_merge(metadata_config) unless metadata_config.nil?

#schema = schema.deep_merge(metadata_config['default']) unless metadata_config['default'].nil?
#schema = schema.deep_merge(metadata_config[Rails.env]) unless metadata_config[Rails.env].nil?


generic_property = schema['properties']['default']

# loop through properties and merge in the default property
schema['properties'].except("default").each do |prop_name, prop|
  schema['properties'][prop_name] = generic_property.deep_merge(prop)
end

#loop through the defined work types to set up the metadata for each
schema['work_types'].except("default").each do |work_type_name, work_type|

  next if work_type.nil?
  work_type = {} unless work_type.is_a? Hash
  schema['work_types'][work_type_name] = {"properties" => {},
#                                          "inputs" => {},
                                          "display_terms" => [],
                                          "required" => [],
                                          "primary" => [],
                                          "controlled" => [],
                                          "multi_controlled" => [],
                                         }

  # optionally set a special default property settings for this work type
  if work_type.key?("properties") && work_type["properties"].key?("default") 
    default_property = generic_property.deep_merge(work_type["properties"]["default"]) 
  end

  # loop through the work type properties, apply defaults, 
  # and populate some some convenient (but redundant)  arrays at startup 
  # to avoid having to loop through properties a bunch of times every page load
  work_type["properties"] ||= {}
  
  work_type["properties"].except("default").each do |property_name, property|
    next if schema['properties'][property_name].nil?
    property ||= {}

    # merge in the settings from the generic property definition 
    property = schema['properties'][property_name].deep_merge(property)
    # make sure the predicate is set correctly
    property['predicate'] = schema['properties'][property_name]['predicate']
    
    # merge in the default property
    property = default_property.deep_merge(property) unless default_property.nil?

    # Move on in case we have a blank property and no default set up somehow.
    next if property.nil?
    
    # change the clearer "faceted => true" to the more functional "render_as => faceted"
    property["render_as"] = "faceted" if !property.key?("render_as") && property["facet"]

    
    # populate useful auxiliary collections of terms
    schema["work_types"][work_type_name]["primary"] << property_name if property["primary"]
    schema["work_types"][work_type_name]["display_terms"] << property_name unless property["hidden"]
    schema["work_types"][work_type_name]["required"] << property_name if property["required"]
    schema["work_types"][work_type_name]["nested"] << property_name if property["nested"]
#    schema["work_types"][work_type_name]["inputs"][property["input"]] << property_name unless property["input"].nil?

    #predicate management
    raise ArgumentError.new("predicate required") if property["predicate"].nil?
    ns_prefix = property["predicate"].split(":").first
    predicate_name = property["predicate"].split(":",2).last

    #sort out the predicate namespace if necessary
    namespaces = schema['namespaces']
    if namespaces.key?(ns_prefix)
      property['predicate'] = namespaces[ns_prefix] + predicate_name
      property['rdf_namespace'] = false
    else
      property['predicate'] = predicate_name
      property['rdf_namespace'] = ns_prefix
    end

    #overwrite the property in the property list
    schema["work_types"][work_type_name]["properties"][property_name] = property

  end # of property loop
end # of work type loop

schema["properties"] = schema["properties"].except("default")

# set the global constant
ScoobySnacks::METADATA_SCHEMA = schema

# generate local classes outside the PCDM 
require 'scooby_snacks/authority_class_creator'

# generate work types
# NOT YET IMPLEMENTED
#require "#{Rails.root}/lib/ucsc/metadata/work_types"
