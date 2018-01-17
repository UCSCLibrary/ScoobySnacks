module ScoobySnacks::SolrBehavior
  extend ActiveSupport::Concern

  class_methods do

    def attribute(name, type, field)
      define_method name do
        type.coerce(self[field])
      end
    end

    def solr_name(*args)
      Solrizer.solr_name(*args)
    end
  end


  #TODO This has to do with solr coercing the right type
  # for each field. I need to remember exactly how this
  # works (this part of the code is old & borrowed)
  module Solr
    class Array
      # @return [Array]
      def self.coerce(input)
        ::Array.wrap(input)
      end
    end

    class String
      # @return [String]
      def self.coerce(input)
        ::Array.wrap(input).first
      end
    end

    class Date
      # @return [Date]
      def self.coerce(input)
        field = String.coerce(input)
        return if field.blank?
        begin
          ::Date.parse(field)
        rescue ArgumentError
          Rails.logger.info "Unable to parse date: #{field.first.inspect}"
        end
      end
    end
  end


  included do
 
    # Loop through all properties from all work types
    ScoobySnacks::METADATA_SCHEMA['properties'].each do  |property_name, property|
      next if respond_to? property_name
      property = {} unless property.is_a? Hash
        
      case property["range"] 
      when "string"
        solr_class = Solr::String
      when "date"
        solr_class = Solr::Date
      else
        is_multiple = property['multiple'].to_s == "true" || property['multiple'].nil? || property['multiple'] == ""
        solr_class = is_multiple ?  Solr::Array : Solr::String
      end

      # define an index attribute for the current property
      attribute property_name.to_sym, solr_class, solr_name(property_name)
           
      # additionally, define a corresponding label attribute 
      # if the property uses a controlled input field
      if property["controlled"].to_s == "true"
        attribute (property_name+'_label').to_sym, solr_class, solr_name(property_name+'_label') 
      end

    end

  end
end
