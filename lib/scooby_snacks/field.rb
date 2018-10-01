module ScoobySnacks
  class Field
    
    attr_reader :name, :label, :oai_element, :oai_ns

    def solr_search_name
      return false unless index?
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

    def index?
      @index ||= (@raw_array['strored'].to_s == "true")
    end

    def sort?
      @sort ||= (@raw_array['sort_field'].to_s == "true")
    end

    def facet?
      @facet ||= (@raw_array['facet'].to_s == "true")
    end

    def search?
      @search ||= (@raw_array['search_field'].to_s == "true")
    end

    def sort?
      @sort ||= (@raw_array['sort_field'].to_s == "true")
    end

    def index? 
      @index ||= (@raw_array['search_result_display'].to_s == "true")
    end

    def date?
      @date ||= (@raw_array['input'].to_s.include? "date")
    end

    def controlled?
      @controlled ||= (@raw_array['input'].to_s.include? "controlled")
    end

    def multiple?
      @multiple ||= (@raw_array['search_result_display'].to_s != "false")
    end

    def facet_limit 
      @raw_array['facet_limit']
    end

    def itemprop
      @raw_array['itemprop']
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
      @raw_array['index_helper_method'].to_sym if @raw_array['index_helper_method']
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

  end
end
