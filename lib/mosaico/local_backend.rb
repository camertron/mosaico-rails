module Mosaico
  class LocalBackend
    attr_reader :base_path, :base_url

    def initialize(base_path, base_url)
      @base_path = base_path
      @base_url = base_url
    end

    def store(source, as:)
      FileUtils.mkdir_p(base_path)
      FileUtils.cp(source, File.join(base_path, as))
    end

    def retrieve(filename)
      File.join(base_path, filename)
    end

    def url_to(filename)
      Mosaico.url_join(base_url, filename)
    end
  end
end
