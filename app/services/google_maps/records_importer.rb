# frozen_string_literal: true

class GoogleMaps::RecordsImporter
  include Imports::Broadcaster

  BATCH_SIZE = 1000
  attr_reader :import, :current_index

  def initialize(import, current_index = 0)
    @import = import
    @batch = []
    @current_index = current_index
  end

  def call(locations)
    Array(locations).each_slice(BATCH_SIZE) do |location_batch|
      batch = location_batch.map { prepare_location_data(_1) }
      bulk_insert_points(batch)
      broadcast_import_progress(import, current_index)
    end
  end

  private

  # rubocop:disable Metrics/MethodLength
  def prepare_location_data(location)
    {
      latitude: location['latitudeE7'].to_f / 10**7,
      longitude: location['longitudeE7'].to_f / 10**7,
      timestamp: parse_timestamp(location),
      altitude: location['altitude'],
      velocity: location['velocity'],
      raw_data: location,
      topic: 'Google Maps Timeline Export',
      tracker_id: 'google-maps-timeline-export',
      import_id: @import.id,
      user_id: @import.user_id,
      created_at: Time.current,
      updated_at: Time.current
    }
  end
  # rubocop:enable Metrics/MethodLength

  def bulk_insert_points(batch)
    unique_batch = deduplicate_batch(batch)

    # rubocop:disable Rails/SkipsModelValidations
    Point.upsert_all(
      unique_batch,
      unique_by: %i[latitude longitude timestamp user_id],
      returning: false,
      on_duplicate: :skip
    )
    # rubocop:enable Rails/SkipsModelValidations
  rescue StandardError => e
    create_notification("Failed to process location batch: #{e.message}")
  end

  def deduplicate_batch(batch)
    batch.uniq do |record|
      [
        record[:latitude].round(7),
        record[:longitude].round(7),
        record[:timestamp],
        record[:user_id]
      ]
    end
  end

  def parse_timestamp(location)
    Timestamps.parse_timestamp(
      location['timestamp'] || location['timestampMs']
    )
  end

  def create_notification(message)
    Notification.create!(
      user: @import.user,
      title: 'Google\'s Records.json Import Error',
      content: message,
      kind: :error
    )
  end
end
