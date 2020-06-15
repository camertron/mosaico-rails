module Mosaico
  class ActiveStoragePlaceholderBackend < ActiveStorageBackend
    def initialize
      super(ActiveStorage::Blob.service, '/mosaico/placeholders')
    end
  end
end
