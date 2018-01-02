module ScoobySnacks::CatalogControllerBehavior
  extend ActiveSupport::Concern  
  included do

    # Loop through all properties
    ScoobySnacks::METADATA_SCHEMA["properties"].each do |prop_name, prop|
       
      # some fields have a "type" that changes their solr name
      name_options = {}
      name_options[:type] = prop["index_type"] if !prop["index_type"].nil?
      prop_solr_name = solr_name(prop_name, prop["index_as"], name_options)
      
      # Add Facet if appropriate
      if prop["facet"].to_s == "true"
        config.add_facet_field solr_name(prop_name, :facetable), label: prop["label"], limit: prop["facet_limit"]
      end
      
      # Add index fields
      if prop["facet"].to_s != "false"
        options = {label: prop["label"]}
        options[:itemprop] = prop["index_itemprop"] if !prop["itemprop"].nil?
        options[:if] = prop["index_if"] if !prop["index_if"].nil?
        options[:itemprop] = prop["index_itemprop"] if !prop["index_itemprop"].nil?
        options[:helper_method] = prop["index_helper_method"].to_sym if !prop["index_helper_method"].nil?

        # link to facet search if facetable
        options[:link_to_search] = solr_name(prop_name, :facetable) if prop["facet"].to_s == "true"

        config.add_index_field prop_solr_name, options
      end

      # Add show field
      config.add_show_field prop_solr_name, label: prop["label"]
      
      # Add search field
      if prop["search_field"].to_s == "true"
        config.add_search_field(prop_name) do |field|
          field.solr_local_parameters = {
            qf: prop_solr_name,
            pf: prop_solr_name
          }
        end
      end

      # Add sort field
      if prop["sort_field"].to_s == true
        config.add_sort_field "#{prop_name} desc", label: "#{prop["label"].downcase} \u25BC"
        config.add_sort_field "#{prop_name} asc", label: "#{prop["label"].downcase} \u25B2"
      end

    end
  end
end
