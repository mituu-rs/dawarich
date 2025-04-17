# frozen_string_literal: true

RSpec.describe Users::SafeSettings do
  describe '#config' do
    context 'with default values' do
      let(:settings) { {} }
      let(:safe_settings) { described_class.new(settings) }

      it 'returns default configuration' do
        expect(safe_settings.config).to eq(
          {
            fog_of_war_meters: 50,
            meters_between_routes: 500,
            preferred_map_layer: 'OpenStreetMap',
            speed_colored_routes: false,
            points_rendering_mode: 'raw',
            minutes_between_routes: 30,
            time_threshold_minutes: 30,
            merge_threshold_minutes: 15,
            live_map_enabled: true,
            route_opacity: 0.6,
            immich_url: nil,
            immich_api_key: nil,
            photoprism_url: nil,
            photoprism_api_key: nil,
            maps: {}
          }
        )
      end
    end

    context 'with custom values' do
      let(:settings) do
        {
          'fog_of_war_meters' => 100,
          'meters_between_routes' => 1000,
          'preferred_map_layer' => 'Satellite',
          'speed_colored_routes' => true,
          'points_rendering_mode' => 'simplified',
          'minutes_between_routes' => 60,
          'time_threshold_minutes' => 45,
          'merge_threshold_minutes' => 20,
          'live_map_enabled' => false,
          'route_opacity' => 0.8,
          'immich_url' => 'https://immich.example.com',
          'immich_api_key' => 'immich-key',
          'photoprism_url' => 'https://photoprism.example.com',
          'photoprism_api_key' => 'photoprism-key',
          'maps' => { 'name' => 'custom', 'url' => 'https://custom.example.com' }
        }
      end
      let(:safe_settings) { described_class.new(settings) }

      it 'returns custom configuration' do
        expect(safe_settings.config).to eq(
          {
            fog_of_war_meters: 100,
            meters_between_routes: 1000,
            preferred_map_layer: 'Satellite',
            speed_colored_routes: true,
            points_rendering_mode: 'simplified',
            minutes_between_routes: 60,
            time_threshold_minutes: 45,
            merge_threshold_minutes: 20,
            live_map_enabled: false,
            route_opacity: 0.8,
            immich_url: 'https://immich.example.com',
            immich_api_key: 'immich-key',
            photoprism_url: 'https://photoprism.example.com',
            photoprism_api_key: 'photoprism-key',
            maps: { 'name' => 'custom', 'url' => 'https://custom.example.com' }
          }
        )
      end
    end
  end

  describe 'individual settings' do
    let(:safe_settings) { described_class.new(settings) }

    context 'with default values' do
      let(:settings) { {} }

      it 'returns default values for each setting' do
        expect(safe_settings.fog_of_war_meters).to eq(50)
        expect(safe_settings.meters_between_routes).to eq(500)
        expect(safe_settings.preferred_map_layer).to eq('OpenStreetMap')
        expect(safe_settings.speed_colored_routes).to be false
        expect(safe_settings.points_rendering_mode).to eq('raw')
        expect(safe_settings.minutes_between_routes).to eq(30)
        expect(safe_settings.time_threshold_minutes).to eq(30)
        expect(safe_settings.merge_threshold_minutes).to eq(15)
        expect(safe_settings.live_map_enabled).to be true
        expect(safe_settings.route_opacity).to eq(0.6)
        expect(safe_settings.immich_url).to be_nil
        expect(safe_settings.immich_api_key).to be_nil
        expect(safe_settings.photoprism_url).to be_nil
        expect(safe_settings.photoprism_api_key).to be_nil
        expect(safe_settings.maps).to eq({})
      end
    end

    context 'with custom values' do
      let(:settings) do
        {
          'fog_of_war_meters' => 100,
          'meters_between_routes' => 1000,
          'preferred_map_layer' => 'Satellite',
          'speed_colored_routes' => true,
          'points_rendering_mode' => 'simplified',
          'minutes_between_routes' => 60,
          'time_threshold_minutes' => 45,
          'merge_threshold_minutes' => 20,
          'live_map_enabled' => false,
          'route_opacity' => 0.8,
          'immich_url' => 'https://immich.example.com',
          'immich_api_key' => 'immich-key',
          'photoprism_url' => 'https://photoprism.example.com',
          'photoprism_api_key' => 'photoprism-key',
          'maps' => { 'name' => 'custom', 'url' => 'https://custom.example.com' }
        }
      end

      it 'returns custom values for each setting' do
        expect(safe_settings.fog_of_war_meters).to eq(100)
        expect(safe_settings.meters_between_routes).to eq(1000)
        expect(safe_settings.preferred_map_layer).to eq('Satellite')
        expect(safe_settings.speed_colored_routes).to be true
        expect(safe_settings.points_rendering_mode).to eq('simplified')
        expect(safe_settings.minutes_between_routes).to eq(60)
        expect(safe_settings.time_threshold_minutes).to eq(45)
        expect(safe_settings.merge_threshold_minutes).to eq(20)
        expect(safe_settings.live_map_enabled).to be false
        expect(safe_settings.route_opacity).to eq(0.8)
        expect(safe_settings.immich_url).to eq('https://immich.example.com')
        expect(safe_settings.immich_api_key).to eq('immich-key')
        expect(safe_settings.photoprism_url).to eq('https://photoprism.example.com')
        expect(safe_settings.photoprism_api_key).to eq('photoprism-key')
        expect(safe_settings.maps).to eq({ 'name' => 'custom', 'url' => 'https://custom.example.com' })
      end
    end
  end
end
