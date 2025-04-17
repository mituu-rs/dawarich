# frozen_string_literal: true

class Points::GeojsonSerializer
  def initialize(points)
    @points = points
  end

  # rubocop:disable Metrics/MethodLength
  def call
    {
      type: 'FeatureCollection',
      features: points.map do |point|
        {
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: [point.lon.to_s, point.lat.to_s]
          },
          properties: PointSerializer.new(point).call
        }
      end
    }.to_json
  end
  # rubocop:enable Metrics/MethodLength

  private

  attr_reader :points
end
