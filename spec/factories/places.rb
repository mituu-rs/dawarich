# frozen_string_literal: true

FactoryBot.define do
  factory :place do
    name { 'MyString' }
    latitude { 54.2905245 }
    longitude { 13.0948638 }
    lonlat { "SRID=4326;POINT(#{longitude} #{latitude})" }

    trait :with_geodata do
      geodata do
        {
          "geometry": {
            "coordinates": [
              13.0948638,
              54.2905245
            ],
            "type": 'Point'
          },
          "type": 'Feature',
          "properties": {
            "osm_id": 5_762_449_774,
            "country": 'Germany',
            "city": 'Stralsund',
            "countrycode": 'DE',
            "postcode": '18439',
            "locality": 'Frankensiedlung',
            "county": 'Vorpommern-Rügen',
            "type": 'house',
            "osm_type": 'N',
            "osm_key": 'amenity',
            "housenumber": '84-85',
            "street": 'Greifswalder Chaussee',
            "district": 'Franken',
            "osm_value": 'restaurant',
            "name": 'Braugasthaus Zum Alten Fritz',
            "state": 'Mecklenburg-Vorpommern'
          }
        }
      end
    end

    # Special trait for testing with nil lonlat
    trait :without_lonlat do
      # Skip validation to create an invalid record for testing
      to_create { |instance| instance.save(validate: false) }
      after(:build) do |place|
        place.lonlat = nil
      end
    end
  end
end
