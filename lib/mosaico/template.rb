module Mosaico
  class Template
    SRC_REGEX = /src\s*=\s*(?:"([^"]*)"|'([^']*)')/.freeze

    attr_reader :name, :dir, :subdirs

    def initialize(name, dir, subdirs)
      @name = name
      @dir = dir
      @subdirs = subdirs
    end

    def list_precomp_assets
      subdirs.flat_map do |subdir|
        # only allow images through for now
        # TODO: what other file types are we going to need?
        Dir.glob(File.join(dir, subdir, '**/*.{jpg,gif,png}'))
      end
    end

    def template_path
      @template_path ||= File.join(dir, "#{full_name}.html")
    end

    def template_url
      Mosaico::Engine.routes.url_helpers.template_path(name)
    end

    # where the template's thumbnails are stored
    def edres_path
      File.join(dir, 'edres')
    end

    def template_content
      @template_content ||= begin
        File.read(template_path).gsub(SRC_REGEX) do
          if subdirs.any? { |subdir| $1.start_with?("#{subdir}/") }
            asset_path = File.join(dir, $1)

            if resolved_asset = Mosaico.resolve_asset(asset_path)
              prefix = Rails.application.config.assets.prefix
              asset_url = Mosaico.url_join(prefix, resolved_asset)
              next "src='#{asset_url}'"
            end
          end

          "src='#{$1}'"
        end
      end
    end

    def asset_paths
      @asset_paths ||= list_precomp_assets.each_with_object({}) do |asset_path, ret|
        short_path = asset_path[(dir.length + 1)..-1]
        ret[short_path] = Mosaico.resolve_asset(asset_path)
      end
    end

    def full_name
      "template-#{name}"
    end

    def url
      Mosaico::Engine.routes.url_helpers.template_path(name)
    end
  end
end
