# frozen_string_literal: true

class ProductsImportChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'ProductsImportChannel'
  end

  def unsubscribed; end
end
