module Mosaico
  class PlaceholderImage < Image
    class << self
      def backend
        Mosaico::Engine.config.placeholder_backend
      end
    end
  end
end
