module ScoobySnacks
  class Field
    
    attr_reader :name, :label, :oai_element, :oai_ns

    def solr_sort_name
      return false unless sort?
      @solr_sort_name ||= Solrizer.solr_name(name, :stored_sortable)
    end

    def initialize name, raw_array
      @raw_array = raw_array
      @name = name
      @label = raw_array['label'] || name.underscore.humanize

      if @raw_array['OAI'] && (oai_split =  @raw_array['OAI'].split(':',2))
        @oai_ns = oai_split.first.downcase
        @oai_element = oai_split.last
      end
    end

    # here we define methods for simple boolean attributes associate with metadata fields
    # ("meta-metadata properties")
    ScoobySnacks::MetadataSchema.boolean_attributes.each do |attribute_name|
      # Skip any attribute we have a custom method for
      next if [:controlled].include? attribute_name
      #define a method for this attribute
      define_method("#{attribute_name}?".to_sym) do
        # For boolean attributes, we cache the result to avoid repeated string comparison operations
        attribute = instance_variable_get("@#{attribute_name}")
        return attribute unless attribute.nil?
        attribute = @raw_array[attribute_name.to_s].to_s.downcase.strip == "true"
        instance_variable_set("@#{attribute_name}", attribute)
        return attribute
      end
    end

    # here we define methods for simple string attributes associate with metadata fields
    # ("meta-metadata properties")
    ScoobySnacks::MetadataSchema.string_attributes.each do |attribute_name|
      # For string attributes, we just pull the result straight from the raw array        
      define_method("#{attribute_name}".to_sym) do
        @raw_array[attribute_name.to_s]
      end
    end

    def example
      return @raw_array["example"] if @raw_array["example"]
      if controlled?
        return "http://id.loc.gov/authorities/names/n2002034393"
      elsif date?
        return "01-01-1901"
      else
        return "Example #{name.titleize}"
      end
    end

    def controlled?
      return @controlled unless @controlled.nil?
      @controlled = false
      @controlled = true if @raw_array['controlled'].to_s == "true"
      @controlled = true if @raw_array['input'].to_s.include? "controlled"
      @controlled = true if (@raw_array['vocabularies'].is_a?(Array) && !@raw_array['vocabularies'].empty?)
      @controlled = true if (@raw_array['vocabulary'].is_a?(Array) && !@raw_array['vocabulary'].empty?)
      @controlled = true if (@raw_array['vocabulary'].is_a?(Hash) && !@raw_array['vocabulary'].empty?)
      return @controlled
    end

    def predicate
      return @predicate if @predicate
      raise ArgumentError.new("invalid predicate definition. Raw array: #{@raw_array.inspect}") if  @raw_array["predicate"].nil?
      namespace_prefix = @raw_array["predicate"].split(":").first
      predicate_name = @raw_array["predicate"].split(":",2).last
      #sort out the predicate namespace if necessary
      namespaces = schema.namespaces
      if namespaces.key?(namespace_prefix) 
        namespace_url = namespaces[namespace_prefix]
        raise ArgumentError.new("invalid predicate definition: #{@raw_array['predicate']}") unless namespace_url.include?("http")
        @predicate = ::RDF::URI.new(namespace_url + predicate_name)
      elsif defined?("::RDF::Vocab::#{namespace_prefix}".constantize)
        @predicate = "::RDF::Vocab::#{namespace_prefix}".constantize.send predicate_name
      else
        raise ArgumentError.new("invalid predicate definition: #{@raw_array['predicate']}")
      end
      @predicate
    end

    def date?
      @date ||= (@raw_array['input'].to_s.downcase.include? "date") || (@raw_array['data_type'].to_s.downcase.include? "date")  
    end

    def itemprop
      @raw_array['index_itemprop'] || @raw_array['itemprop']
    end

    def helper_method
      method_name = (@raw_array['index_helper_method'] || @raw_array['helper_method'])
      method_name.to_sym unless method_name.nil?
    end

    def search?
      searchable?
    end

    def sort?
      sortable?
    end

    def index_itemprop
      itemprop
    end

    def oai?
      !@oai_element.nil? && !@oai_ns.nil?
    end

    def display_options
      options = {label: label}
      if date?
        options[:render_as] = :date
      elsif searchable? && linked_to_search?
        options[:render_as] = :linked 
        options[:search_field] = name
      end
      return options
    end

    def in_display_group? group_name
      display_groups.each { |display_group| break true if (display_group.downcase == group_name.to_s.downcase) }==true
    end

    def search_result_display?
      in_display_group? "search_result"
    end

    def display_groups
      @raw_array['display_groups'] || Array.wrap(@raw_array['display_group'])     
    end

    def display_group
      display_groups.first
    end

    def vocabularies
      @raw_array['vocabularies'] || Array.wrap(@raw_array['vocabulary'])
    end

    def primary_vocabulary
      vocabularies.first
    end

    def solr_names
      solr_descriptors.reduce([]){|names, desc| names << solr_name(desc)}
    end

    def solr_name(descriptor = nil)
      descriptor ||= solr_descriptors.first
      Solrizer.solr_name(name,descriptor,type: solr_data_type)
    end

    def solr_search_name
      return "" unless searchable?
      solr_name(:stored_searchable)
    end

    def solr_facet_name
      return "" unless facet?
      solr_name(:facetable)
    end

    def solr_sort_name
      return "" unless sort?
      solr_name(:stored_sortable)
    end

    def solr_descriptors
      descriptors = []
      descriptors << :symbol if (symbol? or [:string,:symbol].include?(@raw_array['data_type'].downcase.to_sym))
      descriptors << :stored_searchable if (searchable? and !descriptors.include?(:symbol))
      descriptors << :facetable if facet?
      descriptors << :displayable if (descriptors.empty? && stored_in_solr?)
      return descriptors
    end

    def solr_data_type
      @raw_array['data_type'].downcase.to_sym || :text
    end

    private

    def schema
      if defined? ScoobySnacks::METADATA_SCHEMA
        return ScoobySnacks::METADATA_SCHEMA
      else
        @schema ||= ScoobySnacks::MetadataSchema.new
      end
    end

  end
end
