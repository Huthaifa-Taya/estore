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

    def import_products; end

    def import_products_from_csv; end

    private

    def verify_admin
      redirect_to root_path unless admin_signed_in?
    end
  end
end
