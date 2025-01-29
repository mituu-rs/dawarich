# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::PhotosController', type: :request do
  let(:user) { create(:user, :with_immich_integration) }
  let(:api_key) { user.api_key }
  let(:start_date) { '2024-01-01' }
  let(:end_date) { '2024-01-02' }
  let!(:immich_image) do
    {
      "id": '7fe486e3-c3ba-4b54-bbf9-1281b39ed15c',
      "deviceAssetId": 'IMG_9913.jpeg-1168914',
      "ownerId": 'f579f328-c355-438c-a82c-fe3390bd5f08',
      "deviceId": 'CLI',
      "libraryId": nil,
      "type": 'IMAGE',
      "originalPath": 'upload/library/admin/2023/2023-06-08/IMG_9913.jpeg',
      "originalFileName": 'IMG_9913.jpeg',
      "originalMimeType": 'image/jpeg',
      "thumbhash": '4RgONQaZqYaH93g3h3p3d6RfPPrG',
      "fileCreatedAt": '2023-06-08T07:58:45.637Z',
      "fileModifiedAt": '2023-06-08T09:58:45.000Z',
      "localDateTime": '2024-01-01T09:58:45.637Z',
      "updatedAt": '2024-08-24T18:20:47.965Z',
      "isFavorite": false,
      "isArchived": false,
      "isTrashed": false,
      "duration": '0:00:00.00000',
      "exifInfo": {
        "make": 'Apple',
        "model": 'iPhone 12 Pro',
        "exifImageWidth": 4032,
        "exifImageHeight": 3024,
        "fileSizeInByte": 1_168_914,
        "orientation": '6',
        "dateTimeOriginal": '2023-06-08T07:58:45.637Z',
        "modifyDate": '2023-06-08T07:58:45.000Z',
        "timeZone": 'Europe/Berlin',
        "lensModel": 'iPhone 12 Pro back triple camera 4.2mm f/1.6',
        "fNumber": 1.6,
        "focalLength": 4.2,
        "iso": 320,
        "exposureTime": '1/60',
        "latitude": 52.11,
        "longitude": 13.22,
        "city": 'Johannisthal',
        "state": 'Berlin',
        "country": 'Germany',
        "description": '',
        "projectionType": nil,
        "rating": nil
      },
      "livePhotoVideoId": nil,
      "people": [],
      "checksum": 'aL1edPVg4ZpEnS6xCRWNUY0pUS8=',
      "isOffline": false,
      "hasMetadata": true,
      "duplicateId": '88a34bee-783d-46e4-aa52-33b75ffda375',
      "resized": true
    }
  end
  let(:immich_data) do
    {
      "albums": {
        "total": 0,
        "count": 0,
        "items": [],
        "facets": []
      },
      "assets": {
        "total": 1000,
        "count": 1000,
        "items": [immich_image]
      }
    }.to_json
  end

  before do
    stub_request(:post, "#{user.settings['immich_url']}/api/search/metadata")
      .to_return(status: 200, body: immich_data)

    stub_request(:get, "#{user.settings['immich_url']}/api/assets/7fe486e3-c3ba-4b54-bbf9-1281b39ed15c/thumbnail?size=preview")
      .to_return(status: 200, body: immich_image.to_json, headers: {})

    stub_request(:get, "#{user.settings['immich_url']}/api/assets/nonexistent/thumbnail?size=preview")
      .to_return(status: 404, body: [].to_json, headers: {})
  end

  path '/api/v1/photos' do
    get 'Lists photos' do
      tags 'Photos'
      produces 'application/json'
      parameter name: :api_key, in: :query, type: :string, required: true
      parameter name: :start_date, in: :query, type: :string, required: true,
                description: 'Start date in ISO8601 format, e.g. 2024-01-01'
      parameter name: :end_date, in: :query, type: :string, required: true,
                description: 'End date in ISO8601 format, e.g. 2024-01-02'

      response '200', 'photos found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :string },
                   latitude: { type: :number, format: :float },
                   longitude: { type: :number, format: :float },
                   localDateTime: { type: :string, format: 'date-time' },
                   originalFileName: { type: :string },
                   city: { type: :string },
                   state: { type: :string },
                   country: { type: :string },
                   type: { type: :string, enum: %w[image video] },
                   orientation: { type: :string, enum: %w[portrait landscape] },
                   source: { type: :string, enum: %w[immich photoprism] }
                 },
                 required: %w[id latitude longitude localDateTime originalFileName city state country type source]
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
        end
      end
    end
  end

  path '/api/v1/photos/{id}/thumbnail' do
    get 'Retrieves a photo' do
      tags 'Photos'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string, required: true
      parameter name: :api_key, in: :query, type: :string, required: true
      parameter name: :source, in: :query, type: :string, required: true
      response '200', 'photo found' do
        schema type: :object,
               properties: {
                 id: { type: :string },
                 latitude: { type: :number, format: :float },
                 longitude: { type: :number, format: :float },
                 localDateTime: { type: :string, format: 'date-time' },
                 originalFileName: { type: :string },
                 city: { type: :string },
                 state: { type: :string },
                 country: { type: :string },
                 type: { type: :string, enum: %w[IMAGE VIDEO image video raw live animated] },
                 orientation: { type: :string, enum: %w[portrait landscape] },
                 source: { type: :string, enum: %w[immich photoprism] }
               }

        let(:id) { '7fe486e3-c3ba-4b54-bbf9-1281b39ed15c' }
        let(:source) { 'immich' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_a(Hash)
          expect(data['id']).to eq(id)
        end
      end

      response '404', 'photo not found' do
        let(:id) { 'nonexistent' }
        let(:api_key) { user.api_key }
        let(:source) { 'immich' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Failed to fetch thumbnail')
        end
      end
    end
  end
end
