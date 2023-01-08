# frozen_string_literal: true

class ImportsChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'ImportsChannel'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
