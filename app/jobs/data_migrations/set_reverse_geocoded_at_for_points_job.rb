# frozen_string_literal: true

class DataMigrations::SetReverseGeocodedAtForPointsJob < ApplicationJob
  queue_as :default

  def perform
    timestamp = Time.current

    Point.where.not(geodata: {})
         .where(reverse_geocoded_at: nil)
         .in_batches(of: 10_000) do |relation|
      # rubocop:disable Rails/SkipsModelValidations
      relation.update_all(reverse_geocoded_at: timestamp)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
