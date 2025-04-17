# frozen_string_literal: true

class DataMigrations::MigratePlacesLonlatJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)

    # Find all places with nil lonlat
    places_to_update = user.places.where(lonlat: nil)

    # For each place, set the lonlat value based on longitude and latitude
    places_to_update.find_each do |place|
      next if place.longitude.nil? || place.latitude.nil?

      # Set the lonlat to a PostGIS point with the proper SRID
      # rubocop:disable Rails/SkipsModelValidations
      place.update_column(:lonlat, "SRID=4326;POINT(#{place.longitude} #{place.latitude})")
      # rubocop:enable Rails/SkipsModelValidations
    end

    # Double check if there are any remaining places without lonlat
    remaining = user.places.where(lonlat: nil)
    return unless remaining.exists?

    # Log an error for these places
    Rails.logger.error("Places with ID #{remaining.pluck(:id).join(', ')} for user #{user.id} could not be updated with lonlat values")
  end
end
