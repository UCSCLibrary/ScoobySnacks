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

    def add_field_semantics(label,solr_name)
      field_semantics.merge!(label => Array.wrap(solr_name)) {|key, old_val, new_val| Array.wrap(old_val) + Array.wrap(new_val)}
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


    attribute :last_reconciled, Solr::Date, solr_name("last_reconciled")

    # Loop through all properties from all work types
    ScoobySnacks::METADATA_SCHEMA.fields.values.each do |field|
      next if respond_to? field.name
      # define an index attribute for the current property
      attribute field.name.to_sym, (field.date? ? Solr::Date : Solr::Array), field.solr_search_name
           
      add_field_semantics(field.oai_element, field.solr_search_name) if (field.oai? && field.oai_ns == 'dc')
    end
  end
end

