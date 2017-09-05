# Really simple uploader, we should probably use carrierwave or something if we
# do this for real.
module Mosaico
  class LocalUploader
    attr_reader :base_path, :base_url

    def initialize(base_path, base_url)
      @base_path = base_path
      @base_url = base_url
    end

    def store!(source, dest)
      FileUtils.mkdir_p(base_path)
      FileUtils.cp(source, File.join(base_path, dest))
    end

    def path_to(file)
      File.join(base_path, file)
    end

    def url_to(file)
      Mosaico.url_join(base_url, file)
    end
  end
end
