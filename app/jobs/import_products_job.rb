# frozen_string_literal: true

class ImportProductsJob < ApplicationJob
  include ActiveJob::Status
  queue_as :default

  def perform(*args)
    # Do something later
    import_from_csv(args[0], args[1])
  end

  def import_from_csv(file, model)
    require 'csv'
    csv_reader = CSV.open(file, headers: true)
    csv_lines = csv_reader.readlines
    file_length = csv_lines.length
    progress.total = file_length
    csv_lines.each do |line|
      progress.increment
      progress_percentage = ((progress.progress / progress.total.to_f) * 100.0).round(2)
      ActionCable.server.broadcast 'NotificationsChannel', "#{progress_percentage}"
      model.create!(line)
    end
    csv_reader.close
    ActionCable.server.broadcast 'NotificationsChannel', 'imported successfully'
  end
end
