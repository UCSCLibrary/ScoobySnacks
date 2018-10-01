module ScoobySnacks::PresenterBehavior
  extend ActiveSupport::Concern
  included do
    ScoobySnacks::METADATA_SCHEMA.display_fields.each do |field|
      next if respond_to? field.name
      delegate field.name.to_sym, to: :solr_document
    end
  end
end

