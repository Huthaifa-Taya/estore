module ActiveRecordExtension
  extend ActiveSupport::Concern

  # add your static(class) methods here
  module ClassMethods
    #E.g: Order.top_ten
    def top_five
      limit(5)
    end

    def latest
      order(created_at: :desc)
    end
  end


    def image_as_thumbnail(width, height)
      image.variant(resize_to_limit: [width, height]).processed if self.image
    end
  end


# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)