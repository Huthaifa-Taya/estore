# frozen_string_literal: true

class ImportProductsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    p '--------------------------------------------------------', args
    import_from_csv(args[0], args[1])
  end

  def import_from_csv(file, _model)
    require 'csv'
    csv_reader = CSV.open(file, headers: true).readlines.each do |line|
      _model.create!(line)
    end
    csv_reader.close
  end

end
