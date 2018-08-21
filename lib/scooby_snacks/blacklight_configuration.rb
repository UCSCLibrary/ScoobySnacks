module ScoobySnacks
  class BlacklightConfiguration
    
    def self.add_all_fields(config)
      self.add_show_fields(config)
      self.add_search_fields(config)
      self.add_facet_fields(config)
      self.add_sort_fields(config)
      self.add_index_fields(config)
    end

    def self.add_show_fields(config)
       ScoobySnacks::METADATA_SCHEMA["properties"].each do |prop_name, prop|
        next unless prop["search_result_display"].to_s != "false"
        config.add_show_field prop_solr_name(prop_name, prop), label: prop["label"]
      end
    end

    def self.add_search_fields(config)
       ScoobySnacks::METADATA_SCHEMA["properties"].each do |prop_name, prop|
        next unless prop["search_field"].to_s == "true"
        config.add_search_field(prop_name) do |field|
          field.solr_local_parameters = {
            qf: prop_solr_name(prop_name, prop),
            pf: prop_solr_name(prop_name, prop)
          }
        end
      end
    end

    def self.add_facet_fields(config)
       ScoobySnacks::METADATA_SCHEMA["properties"].each do |prop_name, prop|
        next unless prop["facet"].to_s == "true"
        config.add_facet_field prop_solr_name(prop_name, prop), label: prop["label"], limit: prop["facet_limit"]
      end
    end

    def self.add_sort_fields(config)
       ScoobySnacks::METADATA_SCHEMA["properties"].each do |prop_name, prop|
        next unless prop["sort_field"].to_s == true
        config.add_sort_field "#{prop_name} desc", label: "#{prop["label"].downcase} \u25BC"
        config.add_sort_field "#{prop_name} asc", label: "#{prop["label"].downcase} \u25B2"
      end
    end

    def self.add_index_fields(config)
      ScoobySnacks::METADATA_SCHEMA["properties"].each do |prop_name, prop|
        next unless prop["search_result_display"].to_s != "false"
        config.add_index_field prop_solr_name(prop_name, prop), self.get_index_options(prop_name, prop)
      end
    end

    def self.prop_solr_name prop_name, prop, type = false
      
      unless prop["vocabularies"].nil? && prop["vocabulary"].nil?
        prop_name += "_label"
      end

      type = :facetable if prop["facetable"]

      if type
        prop_solr_name = Solrizer.solr_name(prop_name, type)
      else
        prop_solr_name = Solrizer.solr_name(prop_name)
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
        options[:link_to_search] = prop_solr_name(prop_name, prop) if prop["facet"].to_s == "true"
        return options
    end

  end
end
