module Mosaico
  class LocalImageBackend < LocalBackend
    def initialize
      super(Rails.root.join('public/mosaico/images').to_s, '/mosaico/images')
    end
  end
end
