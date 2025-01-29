# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Jobs::Create do
  describe '#call' do
    before { allow(DawarichSettings).to receive(:reverse_geocoding_enabled?).and_return(true) }

    context 'when job_name is start_reverse_geocoding' do
      let(:user) { create(:user) }
      let(:points) do
        (1..4).map do |i|
          create(:point, user:, timestamp: 1.day.ago + i.minutes)
        end
      end

      let(:job_name) { 'start_reverse_geocoding' }

      it 'enqueues reverse geocoding for all user points' do
        allow(ReverseGeocodingJob).to receive(:perform_later).and_return(nil)

        described_class.new(job_name, user.id).call

        points.each do |point|
          expect(ReverseGeocodingJob).to have_received(:perform_later).with(point.class.to_s, point.id)
        end
      end
    end

    context 'when job_name is continue_reverse_geocoding' do
      let(:user) { create(:user) }
      let(:points_without_address) do
        (1..4).map do |i|
          create(:point, user:, country: nil, city: nil, timestamp: 1.day.ago + i.minutes)
        end
      end

      let(:points_with_address) do
        (1..5).map do |i|
          create(:point, user:, country: 'Country', city: 'City', timestamp: 1.day.ago + i.minutes)
        end
      end

      let(:job_name) { 'continue_reverse_geocoding' }

      it 'enqueues reverse geocoding for all user points without address' do
        allow(ReverseGeocodingJob).to receive(:perform_later).and_return(nil)

        described_class.new(job_name, user.id).call

        points_without_address.each do |point|
          expect(ReverseGeocodingJob).to have_received(:perform_later).with(point.class.to_s, point.id)
        end
      end
    end

    context 'when job_name is invalid' do
      let(:user) { create(:user) }
      let(:job_name) { 'invalid_job_name' }

      it 'raises an error' do
        expect { described_class.new(job_name, user.id).call }.to raise_error(Jobs::Create::InvalidJobName)
      end
    end
  end
end
