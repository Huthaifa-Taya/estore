# frozen_string_literal: true

class Product < ApplicationRecord
  include ProductsFilters
  has_and_belongs_to_many :categories
  belongs_to :store
  belongs_to :user, -> { where role: [1, 2] }
  has_many :order_product_records
  has_many :orders, through: :order_product_records
  has_one_attached :image
  has_many_attached :pictures
  has_rich_text :body

  paginates_per 8

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock_quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :produced_at, presence: true, format: { with: /\A\d{4}-\d{2}-\d{2}\z/,
                                                    message: 'must be in the format YYYY-MM-DD' }
  validates :expires_at, presence: true, format: { with: /\A\d{4}-\d{2}-\d{2}\z/,
                                                   message: 'must be in the format YYYY-MM-DD' }

  # Ensure that the end date is after the start date
  validate :end_date_is_after_start_date
  scope :price_less_than, ->(value) { where('price < ?', value) }
  scope :price_more_than, ->(value) { where('price > ?', value) }
  scope :price_in_between, ->(values) { where(price: (values[:lower_val]..values[:upper_val])) }

  private

  def end_date_is_after_start_date
    return if expires_at.blank? || produced_at.blank?

    return unless expires_at < produced_at

    errors.add(:expires_at, 'must be after the production date')
  end
end
