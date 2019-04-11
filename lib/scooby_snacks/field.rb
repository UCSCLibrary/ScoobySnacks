module ScoobySnacks
  class Field
    
    attr_reader :name, :label, :oai_element, :oai_ns

    def solr_search_name
      #return false unless index?
      @solr_search_name ||= Solrizer.solr_name(name)
    end

    def solr_facet_name
      return false unless facet?
      @solr_facet_name ||= Solrizer.solr_name(name,:symbol)
    end

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

    def schema
      ScoobySnacks::METADATA_SCHEMA
    end

    def facet?
      @facet ||= schema.facet? name
    end

    def search?
      @search ||= schema.searchable? name
    end

    def sort?
      @sort ||= schema.sortable? name
    end

    def index? 
      @index ||= schema.index? name
    end

    def date?
      @date ||= (@raw_array['input'].to_s.downcase.include? "date") || (@raw_array['data_type'].to_s.downcase.include? "date")  
    end

    def controlled?
      @controlled ||= schema.controlled? name
    end

    def multiple?
      @multiple ||= (@raw_array['multiple'].to_s != "false")
    end

    def facet_limit 
      @raw_array['facet_limit']
    end

    def itemprop
      @raw_array['index_itemprop'] || @raw_array['itemprop']
    end

    def index_itemprop
      itemprop
    end

    def predicate_name
      @raw_array['predicate']
    end

    def predicate
      return @predicate unless @predicate.nil?
      if rdf_namespace
        @predicate = "::RDF::Vocab::#{rdf_namespace}".constantize.send predicate_name
      elsif predicate_name.include?("http")
        @predicate = ::RDF::URI.new predicate_name
      else
        raise ArgumentError.new("invalid predicate definition")
      end
    end

    def helper_method
      method_name = (@raw_array['index_helper_method'] || @raw_array['helper_method'])
      method_name.to_sym unless method_name.nil?
    end

    def rdf_namespace
      @raw_array['rdf_namespace']
    end

    def solr_class

    end

    def oai?
      !@oai_element.nil? && !@oai_ns.nil?
    end

    def input
      @raw_array['input']
    end

    def definition
      @raw_array['definition']
    end

    def vocabularies
      @raw_array['vocabularies'] || [@raw_array['vocabulary']]
    end

    def primary_vocabulary
      vocabularies.first
    end

  end
end
