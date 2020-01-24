module ScoobySnacks
  class MetadataSchema

    attr_reader :fields, :namespaces
    
    SS_BOOLEAN_ATTRIBUTES = [:facet,
                             :symbol,
                             :searchable,
                             :sortable,
                             :multiple, 
                             :full_text_searchable,
                             :required,
                             :work_title, 
                             :hidden,
                             :stored_in_solr,
                             :controlled,
                             :inheritable]

    SS_STRING_ATTRIBUTES = [:facet_limit, 
                            :helper_method, 
                            :input, 
                            :definition,
                            :example]

    SS_DISPLAY_GROUPS = [:primary,
                         :secondary, 
                         :search_result, 
                         :editor_primary]

    # override this locally to define app-specific attributes
    def self.custom_boolean_attributes
      []
    end
    
    # override this locally to define app-specific attributes
    def self.custom_string_attributes
      []
    end

    # override this locally to define app-specific display groups
    def self.custom_display_groups
      []
    end

    def self.boolean_attributes
      SS_BOOLEAN_ATTRIBUTES + custom_boolean_attributes
    end

    def self.string_attributes
      SS_STRING_ATTRIBUTES + custom_string_attributes
    end

    def self.display_groups
      SS_DISPLAY_GROUPS + custom_display_groups
    end

    def self.define_display_group_methods display_groups
      # define methods to list display group contents
      display_groups.each do |display_group|

        define_method("#{display_group}_display_field_names") do 
          field_names = instance_variable_get("@#{display_group}_display_field_names")
          if field_names.nil?
            send("#{display_group}_display_fields".to_sym).map{|field| field.name}
          else
            field_names
          end
        end

        define_method("#{display_group}_display_fields") do 
          field_names = instance_variable_get("@#{display_group}_display_field_names")
          if field_names.nil?
            fields = all_fields.select{|field| field.in_display_group?(display_group)}
            instance_variable_set("@#{display_group}_display_field_names", fields.map{|field| field.name}) 
            fields
          else
            field_names.map{|name| get_field(name)}
          end
        end   
      end
    end

    define_display_group_methods(display_groups)

    def self.define_boolean_attribute_methods boolean_attributes

      # Define methods to cache and return lists of fields & field names
      # that share certain boolean characteristics (controlled, required, etc). 
      boolean_attributes.each do |attribute|
        # Skip any attribute we have a custom method for      
        next if [:work_title].include? attribute
        define_method("#{attribute}_fields".to_sym) do
          @fields.values.select{|field| field.send("#{attribute}?".to_sym)}
        end
        define_method("#{attribute}_field_names".to_sym) do
          field_names = send("#{attribute}_fields".to_sym).map{|field| field.name}
          instance_variable_set("@#{attribute}_field_names".to_sym, field_names)
        end
      end
    end

    define_boolean_attribute_methods(boolean_attributes)

    def initialize (schema_config_path: nil, raw_schema: nil)
      schema_config_path ||= default_schema_config_path
      raw_schema ||= YAML.load_file(schema_config_path)
      @namespaces = raw_schema['namespaces']
      raw_fields = (raw_schema['fields'] || raw_schema['properties'])
      @fields = raw_fields.except('default').keys.reduce({}) do |fields, field_name|
        field = raw_fields['default'].deep_merge raw_fields[field_name]
        fields[field_name] = ScoobySnacks::Field.new(field_name,field)
        fields
      end
    end
    
    def get_field(name)
      @fields[name.to_s] || @fields[label_map[name.to_s]]
    end

    def get_property(name)
      get_field(name)
    end

    def all_field_names
      @fields.keys
    end

    def all_fields
      @fields.values
    end

    def default_text_search_solrized_field_names
      # Include all fields marked for full text search that are also individual search fields
      # and therefore excluded from the 'all_text_timv' search field
      field_names = (full_text_searchable_field_names & searchable_field_names).uniq
      field_solr_names = field_names.map{|field_name| get_field(field_name).solr_search_name }
      return( field_solr_names + [full_text_field_name] )
    end

    def full_text_field_name
      "all_text_timv"
    end

    def work_title_field
      @fields.values.select{|field| field.in_display_group?("title") || field.work_title?}.first
    end

    def work_title_field_name
      work_title_field.name
    end

    def display_field_names
      primary_display_field_names + secondary_display_field_names
    end

    def display_fields
      primary_display_fields + secondary_display_fields
    end

    # A few aliases for these methods since I've been using both conventions
    def sort_fields
      sortable_fields
    end

    def sort_field_names
      sortable_field_names
    end

    def search_fields
      searchable_fields
    end

    def search_field_names
      searchable_field_names
    end

    private

    def label_map
      @label_map ||= @fields.values.reduce({}){|map,field| map[field.label] = field.name if field.label.present?; map }
    end

    def default_schema_config_path
      @schema_config_path ||= File.join(Rails.root.to_s,'config',schema_config_filename)
    end

    def schema_config_filename
      "metadata.yml"
    end

  end
end
