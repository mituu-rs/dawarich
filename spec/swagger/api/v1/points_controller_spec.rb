# frozen_string_literal: true

require 'swagger_helper'

describe 'Points API', type: :request do
  path '/api/v1/points' do
    get 'Retrieves all points' do
      tags 'Points'
      produces 'application/json'
      parameter name: :api_key, in: :query, type: :string, required: true, description: 'API Key'
      parameter name: :start_at, in: :query, type: :string,
                description: 'Start date (i.e. 2024-02-03T13:00:03Z or 2024-02-03)'
      parameter name: :end_at, in: :query, type: :string,
                description: 'End date (i.e. 2024-02-03T13:00:03Z or 2024-02-03)'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Number of points per page'
      parameter name: :order, in: :query, type: :string, required: false,
                description: 'Order of points, valid values are `asc` or `desc`'
      response '200', 'points found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id:                { type: :integer },
                   battery_status:    { type: :number },
                   ping:              { type: :number },
                   battery:           { type: :number },
                   tracker_id:        { type: :string },
                   topic:             { type: :string },
                   altitude:          { type: :number },
                   longitude:         { type: :number },
                   velocity:          { type: :number },
                   trigger:           { type: :string },
                   bssid:             { type: :string },
                   ssid:              { type: :string },
                   connection:        { type: :string },
                   vertical_accuracy: { type: :number },
                   accuracy:          { type: :number },
                   timestamp:         { type: :number },
                   latitude:          { type: :number },
                   mode:              { type: :number },
                   inrids:            { type: :array },
                   in_regions:        { type: :array },
                   raw_data:          { type: :string },
                   import_id:         { type: :string },
                   city:              { type: :string },
                   country:           { type: :string },
                   created_at:        { type: :string },
                   updated_at:        { type: :string },
                   user_id:           { type: :integer },
                   geodata:           { type: :string },
                   visit_id:          { type: :string }
                 }
               }

        let(:user)      { create(:user) }
        let(:areas)     { create_list(:area, 3, user:) }
        let(:api_key)   { user.api_key }
        let(:start_at)  { Time.zone.now - 1.day }
        let(:end_at)    { Time.zone.now }
        let(:points) do
          (1..10).map do |i|
            create(:point, user:, timestamp: 2.hours.ago + i.minutes)
          end
        end

        run_test!
      end
    end

    post 'Creates a batch of points' do
      request_body_example value: {
        locations: [
          {
            type: 'Feature',
            geometry: {
              type: 'Point',
              coordinates: [-122.40530871, 37.74430413]
            },
            properties: {
              timestamp: '2025-01-17T21:03:01Z',
              horizontal_accuracy: 5,
              vertical_accuracy: -1,
              altitude: 0,
              speed: 92.088,
              speed_accuracy: 0,
              course: 27.07,
              course_accuracy: 0,
              track_id: '799F32F5-89BB-45FB-A639-098B1B95B09F',
              device_id: '8D5D4197-245B-4619-A88B-2049100ADE46'
            }
          }
        ]
      }
      tags 'Batches'
      consumes 'application/json'
      parameter name: :locations, in: :body, schema: {
        type: :object,
        properties: {
          type: { type: :string },
          geometry: {
            type: :object,
            properties: {
              type: { type: :string },
              coordinates: { type: :array, items: { type: :number } }
            }
          },
          properties: {
            type: :object,
            properties: {
              timestamp: { type: :string },
              horizontal_accuracy: { type: :number },
              vertical_accuracy: { type: :number },
              altitude: { type: :number },
              speed: { type: :number },
              speed_accuracy: { type: :number },
              course: { type: :number },
              course_accuracy: { type: :number },
              track_id: { type: :string },
              device_id: { type: :string }
            }
          }
        },
        required: %w[geometry properties]
      }

      parameter name: :api_key, in: :query, type: :string, required: true, description: 'API Key'

      response '200', 'Batch of points being processed' do
        let(:file_path) { 'spec/fixtures/files/points/geojson_example.json' }
        let(:file) { File.open(file_path) }
        let(:json) { JSON.parse(file.read) }
        let(:params) { json }
        let(:locations) { params['locations'] }
        let(:api_key) { create(:user).api_key }

        run_test!
      end

      response '401', 'Unauthorized' do
        let(:file_path) { 'spec/fixtures/files/points/geojson_example.json' }
        let(:file) { File.open(file_path) }
        let(:json) { JSON.parse(file.read) }
        let(:params) { json }
        let(:locations) { params['locations'] }
        let(:api_key) { 'invalid_api_key' }

        run_test!
      end
    end
  end

  path '/api/v1/points/{id}' do
    delete 'Deletes a point' do
      tags 'Points'
      produces 'application/json'
      parameter name: :api_key, in: :query, type: :string, required: true, description: 'API Key'
      parameter name: :id, in: :path, type: :string, required: true, description: 'Point ID'

      response '200', 'point deleted' do
        let(:user)    { create(:user) }
        let(:point)   { create(:point, user:) }
        let(:api_key) { user.api_key }
        let(:id)      { point.id }

        run_test!
      end
    end
  end
end
