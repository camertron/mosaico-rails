require 'mosaico/engine'
require 'mosaico/mce_skin'
require 'mosaico/template'
require 'mosaico/versafix_template'
require 'mosaico/version'

require 'uri'

begin
  require 'sprockets/rails/task'

  Sprockets::Rails::Task.class_eval do
    def initialize_with_retain(*args)
      initialize_without_retain(*args)
      Mosaico.sprockets_task = self
    end

    alias_method :initialize_without_retain, :initialize
    alias_method :initialize, :initialize_with_retain
  end
rescue LoadError
end

module Mosaico
  DEFAULT_LOCALE = :en

  autoload :LocalImageBackend,               'mosaico/local_image_backend'
  autoload :LocalPlaceholderBackend,         'mosaico/local_placeholder_backend'
  autoload :LocalBackend,                    'mosaico/local_backend'
  autoload :ActiveStorageImageBackend,       'mosaico/active_storage_image_backend'
  autoload :ActiveStoragePlaceholderBackend, 'mosaico/active_storage_placeholder_backend'
  autoload :ActiveStorageBackend,            'mosaico/active_storage_backend'

  class << self
    include Mosaico::Engine.routes.url_helpers

    attr_writer :default_locale
    attr_accessor :sprockets_task

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

    def mce_plugin_assets
      @mce_plugin_assets ||= Dir.chdir(Mosaico.vendor_asset_root) do
        Dir.glob(File.join(*%w(mosaico dist vendor plugins * plugin.js))).each_with_object({}) do |asset_path, ret|
          name = File.dirname(asset_path).split(File::SEPARATOR).last
          ret[name] = resolve_asset(asset_path)
        end
      end
    end

    def mce_theme_assets
      @mce_theme_assets ||= Dir.chdir(Mosaico.vendor_asset_root) do
        Dir.glob(File.join(*%w(mosaico dist vendor themes * theme.js))).each_with_object({}) do |asset_path, ret|
          name = File.dirname(asset_path).split(File::SEPARATOR).last
          ret[name] = resolve_asset(asset_path)
        end
      end
    end

    def mce_skin_assets
      @mce_skin_assets ||= mce_skins.each_with_object({}) do |(name, skin), ret|
        ret[name] = skin.asset_paths
      end
    end

    def mce_skins
      @mce_skins ||= Dir.chdir(Mosaico.vendor_asset_root) do
        Dir.glob(File.join(*%w(mosaico dist vendor skins *))).each_with_object({}) do |skin_path, ret|
          name = File.basename(skin_path)
          ret[name] = Mosaico::MceSkin.new(name, skin_path)
        end
      end
    end

    def resolve_asset(asset_path)
      uri = URI.parse(asset_path.gsub(File::SEPARATOR, '/'))

      if Rails.application.config.assets.compile || Mosaico.sprockets_task
        env = Rails.application.assets || Mosaico.sprockets_task.environment
        asset = env.find_asset(uri.path)

        path = if Rails.application.config.assets.digest
          asset.try(&:digest_path)
        else
          asset.try(&:logical_path)
        end

        return nil unless path
        uri.path = path
        uri.to_s
      else
        parts = uri.path.split('/')

        0.upto(parts.size - 1) do |i|
          candidate = File.join(*parts[i..-1])

          if found = Rails.application.assets_manifest.assets[candidate]
            uri.path = found
            return uri.to_s
          end
        end

        nil
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
