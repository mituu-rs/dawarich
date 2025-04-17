# frozen_string_literal: true

class Export < ApplicationRecord
  belongs_to :user

  enum :status, { created: 0, processing: 1, completed: 2, failed: 3 }
  enum :file_format, { json: 0, gpx: 1 }

  validates :name, presence: true

  has_one_attached :file

  after_commit -> { ExportJob.perform_later(id) }, on: :create
  after_commit -> { remove_attached_file }, on: :destroy

  def process!
    Exports::Create.new(export: self).call
  end

  def migrate_to_new_storage
    file.attach(io: File.open("public/#{url}"), filename: name)
    update!(url: nil)

    File.delete("public/#{url}")
  rescue StandardError => e
    Rails.logger.debug("Error migrating export #{id}: #{e.message}")
  end

  private

  def remove_attached_file
    file.purge_later

    File.delete("public/#{url}")
  rescue StandardError => e
    Rails.logger.debug("Error removing export #{id}: #{e.message}")
  end
end
