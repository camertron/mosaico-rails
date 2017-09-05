require 'mime/types'

module Mosaico
  class Image < ActiveRecord::Base
    def content_type
      MIME::Types[mime_type].first.content_type
    end
  end
end
