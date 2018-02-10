module Mosaico
  class Template
    SRC_REGEX = /src\s*=\s*(?:"([^"]*)"|'([^']*)')/.freeze

    attr_reader :name, :dir, :subdirs, :registered

    def initialize(name, dir, subdirs)
      @name = name
      @dir = dir
      @subdirs = subdirs
      @registered = false
    end

    def register!
      return if registered?
      before_register
      @registered = true
      after_register
    end

    alias_method :registered?, :registered

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
            if replacement_url = replacement_asset_url(File.join(dir, $1))
              next "src='#{replacement_url}'"
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

    private

    def replacement_asset_url(asset_path)
      if resolved_asset = Mosaico.resolve_asset(asset_path)
        prefix = Rails.application.config.assets.prefix
        Mosaico.url_join(prefix, resolved_asset)
      end
    end

    def before_register
      Rails.application.config.assets.precompile += list_precomp_assets
    end

    def after_register
    end

    def list_precomp_assets
      subdirs.flat_map do |subdir|
        # only allow images through for now
        # TODO: what other file types are we going to need?
        Dir.glob(File.join(dir, subdir, '**/*.{jpg,gif,png}'))
      end
    end
  end
end
