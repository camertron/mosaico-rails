module Mosaico
  class LocalPlaceholderUploader < LocalUploader
    def initialize
      super(Rails.root.join('public/mosaico/placeholders').to_s, '/mosaico/placeholders')
    end
  end
end
