require 'mosaico/engine'
require 'mosaico/template'
require 'mosaico/versafix_template'
require 'mosaico/version'

module Mosaico
  DEFAULT_LOCALE = :en

  autoload :LocalImageBackend,       'mosaico/local_image_backend'
  autoload :LocalPlaceholderBackend, 'mosaico/local_placeholder_backend'
  autoload :LocalBackend,            'mosaico/local_backend'

  class << self
    include Mosaico::Engine.routes.url_helpers

    attr_writer :default_locale

    def register_template(name, dir, subdirs: ['edres', 'img'], template_class: Template)
      templates[name] = template_class.new(name, dir, subdirs).tap(&:register!)
    end

    def find_template(name)
      templates[name]
    end

    def templates
      @templates ||= {}
    end

    def vendor_asset_root
      @vendor_asset_root ||= Mosaico::Engine.root.join(
        'vendor', 'assets', "mosaico-#{Mosaico::MOSAICO_VERSION}"
      )
    end

    def vendor_template_root
      @vendor_template_root ||= vendor_asset_root.join('mosaico', 'templates')
    end

    def vendor_lang_root
      @vendor_lang_root ||= vendor_asset_root.join('mosaico', 'dist', 'lang')
    end

    def vendor_font_root
      @vendor_font_root ||= Mosaico::Engine.root.join(
        'vendor', 'assets', 'fonts'
      )
    end

    def url_join(*segments)
      segments.compact!

      # this regex strips off leading and trailing forward slashes
      joined = segments.map { |p| p.sub(/\A\/?(.*?)\/?\z/, "\\1") }.join('/')

      # handle absolute URLs
      segments.first.start_with?('/') ? "/#{joined}" : joined
    end

    def resolve_asset(asset_path)
      if Rails.application.config.assets.compile
        asset = Rails.application.assets.find_asset(asset_path)

        if Rails.application.config.assets.digest
          asset.try(&:digest_path)
        else
          asset.try(&:logical_path)
        end
      else
        Rails.application.assets_manifest.assets[asset_path]
      end
    end

    def available_locales
      @available_locales ||= begin
        Dir.chdir(vendor_lang_root) do
          Dir.glob('*.json').map do |file|
            file.chomp(File.extname(file)).sub('mosaico-', '').to_sym
          end
        end
      end
    end

    def locale
      @locale ||= default_locale
    end

    def locale=(new_locale)
      @locale = if available_locales.include?(new_locale.to_sym)
        new_locale.to_sym
      else
        default_locale
      end
    end

    def default_locale
      @default_locale ||= DEFAULT_LOCALE
    end
  end
end
