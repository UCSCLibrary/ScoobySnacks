module ScoobySnacks
  class BlacklightConfiguration
    
    def self.add_index_fields(config)
      ScoobySnacks::METADATA_SCHEMA["properties"].each do |prop_name, prop|
        next unless prop["search_result_display"].to_s != "false"
        config.add_index_field prop_solr_name(prop_name, prop), self.get_index_options(prop_name, prop)
      end
    end

    def self.prop_solr_name prop_name, prop
      if prop["vocabularies"].nil? && prop["vocabulary"].nil?
        prop_solr_name = Solrizer.solr_name(prop_name)
      else
        prop_solr_name = Solrizer.solr_name(prop_name + "_label")
      end
    end

    def self.get_index_options prop_name, prop
        options = {}
        options[:label] =  prop["label"]
        options[:itemprop] = prop["index_itemprop"] if !prop["itemprop"].nil?
        options[:if] = prop["index_if"] if !prop["index_if"].nil?
        options[:itemprop] = prop["index_itemprop"] if !prop["index_itemprop"].nil?
        options[:helper_method] = prop["index_helper_method"].to_sym if !prop["index_helper_method"].nil?

        # link to facet search if facetable
        options[:link_to_search] = Solrizer.solr_name(prop_name, :facetable) if prop["facet"].to_s == "true"
        return options
    end

  end
end
