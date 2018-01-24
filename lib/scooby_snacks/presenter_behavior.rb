module ScoobySnacks::PresenterBehavior
  extend ActiveSupport::Concern
  included do
    schema = ScoobySnacks::METADATA_SCHEMA
    schema["properties"].each do |property_name, property|
      next if respond_to? property_name
      next if property["hidden"]
      delegate property_name.to_sym, to: :solr_document
      delegate "#{property_name}_label".to_sym, to: :solr_document
    end
    end
end

