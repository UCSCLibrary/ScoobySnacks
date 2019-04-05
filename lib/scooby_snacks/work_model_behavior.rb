module ScoobySnacks::WorkModelBehavior
  # A model mixin to define metadata 
  # properties and options based on
  # the schema configuration files
  extend ActiveSupport::Concern

  included do

    # Special hidden property to store the last reconciliation date
    property :last_reconciled, predicate: ::RDF::Vocab::XHTML.index, multiple: false
    
    id_blank = proc { |attributes| attributes[:id].blank? }

    schema = ScoobySnacks::METADATA_SCHEMA

    schema.fields.each do |field_name, field|
      # Define the property and its indexing
      # unless it is already defined (e.g. in hyrax core)
      unless respond_to? field.name.to_sym
        property field.name.to_sym, {predicate: field.predicate, multiple: field.multiple?}  do |index| 
          index.as :stored_searchable
        end
      end
    end #end fields loop

    schema.controlled_field_names.each do |field_name|
      accepts_nested_attributes_for field_name.to_sym, reject_if: id_blank, allow_destroy: true
    end

    # used by Hyrax, I think
    # (taken from Hyrax::BasicMetadata)
    # I'm not sure whether/how the scholarsphere stuff is used
    property :label, predicate: ActiveFedora::RDF::Fcrepo::Model.downloadFilename, multiple: false
    property :relative_path, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#relativePath'), multiple: false
    property :import_url, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#importUrl'), multiple: false
    
  end

end

