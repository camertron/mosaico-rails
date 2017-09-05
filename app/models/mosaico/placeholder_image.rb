module Mosaico
  class PlaceholderImage < Image
    class << self
      def uploader
        Mosaico::Engine.config.placeholder_uploader
      end
    end
  end
end
