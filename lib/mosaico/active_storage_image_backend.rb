module Mosaico
  class ActiveStorageImageBackend < ActiveStorageBackend
    def initialize
      super(ActiveStorage::Blob.service, '/mosaico/images')
    end
  end
end
