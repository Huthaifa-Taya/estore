# frozen_string_literal: true

module CsvImporter
  def self.import_from_csv(file_csv, _model)
    # Open the file in read-only mode
    File.open(file_csv, 'r') do |file|
      file_size = file.size
      chunk_size = file_size / 4
      threads = []
      headers = %i[id name price stock_quantity produced_at expires_at user_id store_id]

      # Create a new thread for each chunk
      4.times do |i|
        threads << Thread.new do
          # Seek to the appropriate position in the file
          file.seek(i * chunk_size)
          data = file.read(chunk_size).split(/\r\n/)

          data.each do |product_string|
            product_attributes = product_string.split(',')
            next if product_attributes[0] == 'id' # skip current line if its headers line

            unless _model.create!(Hash[headers.zip(product_attributes)])
              return false
            end
          end
        end
      end

      # Wait for all the threads to complete
      threads.each(&:join)
      p ' ********************************THREADS ********************************', threads[0].methods
      return true
    end
  end
end
