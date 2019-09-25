module ScoobySnacks::SolrBehavior
  extend ActiveSupport::Concern

  class_methods do

    def attribute(name, type, field)
      define_method name do
        type.coerce(self[field])
      end
    end

    def solr_name(*args)
      if ScoobySnacks::METADATA_SCHEMA.all_field_names.include?(args.first)
        ScoobySnacks::METADATA_SCHEMA.get_field(args.first).solr_name
      else
        Solrizer.solr_name(*args)
      end
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
      def self.coerce(inputs)
        ::Array.wrap(inputs).reject{|input| input.blank?}.map do |input|
          field = String.coerce(input)
          begin
            if (field.to_i.to_s == field) && (field.to_i < 3000)
              ::Date.new(field.to_i)
            else
              ::Date.parse(field)
            end
          rescue ArgumentError
            Rails.logger.info "Unable to parse date: #{field.inspect}"
          end
        end
      end
    end
  end


  included do

    # Loop through all properties from all work types
    ScoobySnacks::METADATA_SCHEMA.stored_in_solr_fields.each do |field|
      next if respond_to? field.name
      # define a attribute for the current property
      attribute(field.name.to_sym, (field.date? ? Solr::Date : Solr::Array), field.solr_name)
    end
  end
end

