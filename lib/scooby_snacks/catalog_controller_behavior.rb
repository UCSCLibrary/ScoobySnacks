module ScoobySnacks::CatalogControllerBehavior
  extend ActiveSupport::Concern  
  included do

    # Loop through all properties
    ScoobySnacks::METADATA_SCHEMA["properties"].each do |prop_name, prop|
      
      # some fields have a "type" that changes their solr name
      name_options = {}

      prop_solr_name = ScoobySnacks::BlacklightConfiguration.prop_solr_name(prop_name, prop)

      # Add Facet if appropriate
      if prop["facet"].to_s == "true"
        config.add_facet_field solr_name(prop_name, :facetable), label: prop["label"], limit: prop["facet_limit"]
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

