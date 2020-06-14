module Mosaico
  class ActiveStorageBackend
    attr_reader :service, :path_prefix

    def initialize(service, path_prefix)
      @service = service
      @path_prefix = path_prefix
    end

    def store(source, as:)
      key = "#{path_prefix}/#{as}"
      @service.upload(key, open(source))
    end

    def retrieve(file)
      key = "#{path_prefix}/#{file}"
      data = @service.download(key)

      tmp_file = Tempfile.new(file, :encoding => 'ascii-8bit')
      tmp_file.write(data)
      tmp_file.close

      tmp_file.path
    end

    def url_to(file)
      key = "#{path_prefix}/#{file}"
      @service.url(key, filename: ActiveStorage::Filename.new(file), expires_in: 1.week, disposition: :inline, content_type: nil)
    end
  end
end
