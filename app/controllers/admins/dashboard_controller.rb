# frozen_string_literal: true

module Admins
  class DashboardController < ApplicationController
    before_action :verify_admin

    def index
      @monitor_data = { stores:
                          { latest: Store.order(created_at: :desc).limit(5), total_count: Store.count },
                        users:
                          {
                            customers: { latest: User.customer.order(created_at: :desc).limit(5),
                                         total_count: User.customer.count },
                            owners: { latest: User.owner.order(created_at: :desc).limit(5),
                                      total_count: User.owner.count },
                            total_count: User.count
                          },
                        products: { latest: Product.order(created_at: :desc).limit(5), total_count: Product.count } }
    end

    def import_products_view; end

    def import_products
      file = params.require(:file).permit(:file)['file']
      save_csv_file(file)
      ImportProductsJob.perform_later(Rails.public_path.join('uploads', file.original_filename).to_s, Product)
      redirect_to root_path, notice: 'Your request is being processed' and return
    end

    private

    def verify_admin
      redirect_to root_path unless admin_signed_in?
    end

    def save_csv_file(uploaded_file)
      File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
        file.write(uploaded_file.read)
      end
    end
  end
end
