module Mosaico
  class UploadedImage < Image
    class << self
      def backend
        Mosaico::Engine.config.image_backend
      end
    end

    def to_json
      {
        deleteType: 'DELETE',
        deleteUrl: url,
        name: file,
        originalName: file,
        size: filesize,
        thumbnailUrl: url,
        type: nil,
        url: url
      }
    end

    def url
      Mosaico::Engine.routes.url_helpers.mosaico_image_path(self)
    end
  end
end
