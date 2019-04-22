module ScoobySnacks
  class BlacklightConfiguration
    
    def self.add_all_fields(config)
      self.add_show_fields(config)
      self.add_search_fields(config)
      self.add_facet_fields(config)
      self.add_sort_fields(config)
      self.add_search_result_display_fields(config)
    end

    def self.add_show_fields(config)
       self.schema.display_fields.each do |field|
         begin
           config.add_show_field field.solr_search_name, label: field.label
         rescue 
           Rails.logger.error "error adding field: #{field.solr_search_name} for property #{field.label}. Redundant definition?"
         end
       end
    end

    def self.add_search_fields(config)
      self.schema.searchable_fields.each do |field|
        config.add_search_field(field.name) do |new_field|
          new_field.label = field.label
          new_field.solr_local_parameters = {
            qf: field.solr_search_name,
            pf: field.solr_search_name
          }
        end
      end
    end
 
    def self.add_facet_fields(config)
       self.schema.facet_fields.each do |field|
         config.add_facet_field field.solr_facet_name, {label: field.label, limit: field.facet_limit}
      end
    end
 
    def self.add_sort_fields(config)
       self.schema.sortable_fields.each do |field|
         config.add_sort_field field.solr_sort_name, label: field.label
      end
    end

    def self.add_search_result_display_fields(config)
       self.schema.search_result_display_fields.each do |field|
         config.add_index_field(field.solr_search_name, self.get_index_options(field))
      end
    end

    def self.get_index_options field
        options = {}
        options[:label] =  field.label || field.name
        options[:index_itemprop] = field.itemprop if field.itemprop
        options[:helper_method] = field.helper_method if field.helper_method
        options[:link_to_search] = field.solr_search_name if field.search?
        return options
    end

    private

    def self.schema
      ScoobySnacks::METADATA_SCHEMA
    end

  end
end
