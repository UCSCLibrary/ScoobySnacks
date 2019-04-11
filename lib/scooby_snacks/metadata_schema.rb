module ScoobySnacks
  class MetadataSchema

    attr_accessor :metadata_config_path
    attr_reader :fields, :label_map, :controlled_field_names, :index_field_names, :sortable_field_names, :searchable_field_names, :facet_field_names, :required_field_names, :primary_display_field_names, :secondary_display_field_names, :admin_only_display_field_names, :full_text_searchable_field_names, :work_title_field_name
    
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
      @admin_only_display_field_names = []
      @index_field_names = []
      @sortable_field_names = []
      @facet_field_names = []
      @searchable_field_names = []
      @full_text_searchable_field_names = []
      @primary_editor_field_names = []

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

        #the following is currently pretty application specific for UCSC.
        # we should add a handle and put this code in our hyrax app.
        unless field['hidden'].to_s == "true"
          # if an optional "primary" flag is set, include it in the primary display group
          @primary_display_field_names << field_name if field['primary'].to_s == "true"
          case field['display_group'].underscore.downcase
          when 'primary'
            @primary_display_field_names << field_name unless @primary_display_field_names.include?(field_name)
          when 'work_title'
            @primary_display_field_names << field_name unless @primary_display_field_names.include?(field_name)
            @work_title_field_name = field_name
          when 'more', 'brief', 'secondary'
            @secondary_display_field_names << field_name
          when 'staff', 'staff_only', 'admin', 'admin_only', 'tertiary'
            @admin_only_display_field_names << field_name
          when 'editor_primary', 'primary_editor'
            @primary_editor_field_names << field_name
          end
        end
        @work_title_field_name = field_name if field['work_title'].to_s.downcase == "true"
        @required_field_names << field_name if field['required'].to_s.downcase == "true"
        @index_field_names << field_name if field['search_result_display'].to_s.downcase == "true"
        @facet_field_names << field_name if field['facet'].to_s.downcase == "true"
        @searchable_field_names << field_name if field['searchable_field'].to_s.downcase == "true"
        @full_text_searchable_field_names << field_name if field['full_text_searchable'].to_s.downcase == "true"
        @sortable_field_names << field_name if field['sortable'].to_s.downcase == "true"

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

    # Some fields may be marked primary, but only for the editor
    def primary_editor_field_names
      (@primary_display_field_names + @primary_editor_field_names + @required_field_names).uniq
    end

    def secondary_editor_field_names
      all_field_names - primary_editor_field_names
    end

    def all_field_names
      @fields.keys
    end

    def display_field_names
      primary_display_field_names + secondary_display_field_names + admin_only_display_field_names
    end

    def display_fields
      display_field_names.map{|name| get_field(name) }
    end

    def sortable_fields
      sortable_field_names.map{|name| get_field(name) }
    end

    def controlled? field_name
      field_name = field_name.name if field_name.is_a ScoobySnacks::Field
      schema.searchable_field_names.include?(field_name)
    end

    def searchable? field_name
      field_name = field_name.name if field_name.is_a ScoobySnacks::Field
      schema.searchable_field_names.include?(field_name)
    end

    def sortable? field_name
      field_name = field_name.name if field_name.is_a ScoobySnacks::Field
      schema.sortable_field_names.include?(field_name)
    end

    def index? field_name
      field_name = field_name.name if field_name.is_a ScoobySnacks::Field
      schema.index_field_names.include?(field_name)
    end

    def facet? field_name
      field_name = field_name.name if field_name.is_a ScoobySnacks::Field
      schema.facet_field_names.include?(field_name)
    end

    def searchable_fields
      searchable_field_names.map{|field_name| get_field(field_name) }
    end

    def required_fields
      required_field_names.map{|field_name| get_field(field_name) }
    end

    def controlled_fields
      controlled_field_names.map{|field_name| get_field(field_name) }
    end

    def default_text_search_solrized_field_names
      # Include all fields marked for full text search that are also individual search fields
      # data frin the rest of the marked fields will be included in the full text field
      field_names = (full_text_searchable_field_names & searchable_field_names)
      field_names = field_names.map{|field_name| get_field(field_name).solr_search_name }
      field_names + [full_text_field_name]
    end

    def full_text_field_name
      "all_text_timv"
    end

    def full_text_searchable_fields
      full_text_searchable_field_names.map{|field_name| get_field(field_name) }
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
