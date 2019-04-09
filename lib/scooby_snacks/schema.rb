module ScoobySnacks
  class Schema

    attr_accessor :metadata_config_path
    attr_reader :fields, :label_map, :controlled_fields, :index_fields, :facet_fields, :required_fields, :primary_display_fields, :secondary_display_fields, :tertiary_display_fields
    
    def initialize (metadata_config_path = nil)

      @metadata_config_path = metadata_config_path || "#{Rails.root.to_s}/config/metadata.yml"
      raw_schema = YAML.load_file("#{Rails.root.to_s}/config/metadata.yml")

      raw_fields = raw_schema['fields'] || raw_schema['properties']

      @label_map = {}
      @fields = {}
      @required_fields = []
      @controlled_fields = []
      @primary_display_fields = []
      @secondary_display_fields = []
      @tertiary_display_fields = []
      @index_fields = []
      @facet_fields = []
      raw_fields.except('default').each do |field_name, field| 

        field = raw_fields['default'].deep_merge(field) 
        @label_map[field['label']] = field_name if field['label']
        if field['input'].to_s.include? "controlled" 
          @controlled_fields << field_name
          field["controlled"] = true 
        end
        unless field['hidden'].to_s == "true"
          case field['display_area']
          when 'primary'
            @primary_display_fields << field_name
            break
          when 'secondary'
            @secondary_display_fields << field_name
            break
          when 'tertiary'
            @tertiary_display_fields << field_name
            break
          end
        end
        @required_fields << field_name if field['required'].to_s == "true"
        @index_fields << field_name if field['search_result_display'].to_s != "false"
        @facet_fields << field_name if field['facet'].to_s != "false"

        #predicate management
        raise ArgumentError.new("predicate required") if field["predicate"].nil?
        ns_prefix = field["predicate"].split(":").first
        predicate_name = field["predicate"].split(":",2).last
        
        #sort out the predicate namespace if necessary
        namespaces = raw_schema['namespaces']
        if namespaces.key?(ns_prefix)
          field['predicate'] = namespaces[ns_prefix] + predicate_name
          field['rdf_namespace'] = false
        else
          field['predicate'] = predicate_name
          field['rdf_namespace'] = ns_prefix
        end

        @fields[field_name] = ScoobySnacks::Field.new(field_name,field)

      end
    end

    def all_field_names
      @fields.keys
    end

    def display_fields
      (primary_display_fields + secondary_display_fields + tertiary_display_fields).map{|name| get_field(name) }
    end

    def get_property(name)
      get_field(name)
    end

    def get_field(name)
      @fields[name.to_s] || @fields[@label_map[name.to_s]]
    end

  end
end
