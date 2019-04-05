module ScoobySnacks
  class MetadataSchema

    attr_accessor :metadata_config_path
    attr_reader :fields, :label_map, :controlled_field_names, :index_field_names, :sort_field_names, :search_field_names, :facet_field_names, :required_field_names, :primary_display_field_names, :secondary_display_field_names, :tertiary_display_field_names
    
    def initialize (metadata_config_path = nil)

      @metadata_config_path = metadata_config_path || "#{Rails.root.to_s}/config/metadata.yml"
      raw_schema = YAML.load_file("#{Rails.root.to_s}/config/metadata.yml")

      raw_fields = raw_schema['fields'] || raw_schema['properties']

      @label_map = {}
      @fields = {}
      @required_field_names = []
      @controlled_field_names = []
      @primary_display_field_names = []
      @secondary_display_field_names = []
      @tertiary_display_field_names = []
      @index_field_names = []
      @sort_field_names = []
      @facet_field_names = []
      @search_field_names = []
      raw_fields.except('default').each do |field_name, field| 

        field = raw_fields['default'].deep_merge(field) 
        @label_map[field['label']] = field_name if field['label']

        if (field['controlled'].to_s == "true") ||
           (field['input'].to_s.include? "controlled") ||
           (field['vocabularies'].is_a?(Array) && !field['vocabularies'].empty?) ||
           (field['vocabulary'].is_a?(Hash) && !field['vocabulary'].empty?)
          @controlled_field_names << field_name
          field["controlled"] = true 
        end

        unless field['hidden'].to_s == "true"
          @primary_display_field_names << field_name if field['primary'].to_s == "true"
          case field['display_area']
          when 'primary', 'work_title'
            @primary_display_field_names << field_name unless @primary_display_field_names.include?(field_name)
          when 'more', 'brief'
            @secondary_display_field_names << field_name
          when 'staff'
            @tertiary_display_field_names << field_name
          end
        end
        @required_field_names << field_name if field['required'].to_s == "true"
        @index_field_names << field_name if field['search_result_display'].to_s != "false"
        @facet_field_names << field_name if field['facet'].to_s != "false"
        @search_field_names << field_name if field['search_field'].to_s != "false"
        @sort_field_names << field_name if field['sort_field'].to_s == "true"

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

#        puts "adding field: #{field_name}"

        @fields[field_name] = ScoobySnacks::Field.new(field_name,field)

      end
    end

    def all_field_names
      @fields.keys
    end

    def display_field_names
      primary_display_field_names + secondary_display_field_names + tertiary_display_field_names
    end

    def display_fields
      display_field_names.map{|name| get_field(name) }
    end

    def sort_fields
      sort_field_names.map{|name| get_field(name) }
    end

    def search_fields
      search_field_names.map{|field_name| get_field(field_name) }
    end

    def required_fields
      required_field_names.map{|field_name| get_field(field_name) }
    end

    def controlled_fields
      controlled_field_names.map{|field_name| get_field(field_name) }
    end

    def index_fields
      index_field_names.map{|field_name| get_field(field_name) }
    end

    def facet_fields
      facet_field_names.map{|field_name| get_field(field_name) }
    end

    def get_property(name)
      get_field(name)
    end

    def get_field(name)
      @fields[name] || @fields[@label_map[name]]
    end

  end
end
