require 'uri'

module Mosaico
  class MceSkin
    CSS_FILES = {
      content: 'content.min.css',
      inline_content: 'content.inline.min.css',
      skin: 'skin.min.css'
    }.freeze

    attr_reader :name, :path, :inline
    alias_method :inline?, :inline

    def initialize(name, path)
      @name = name
      @path = path
    end

    def absolute_path
      @absolute_path ||= Mosaico.vendor_asset_root.join(path)
    end

    def list_precompile_assets
      @precompile_assets ||= list_css_assets.values + list_image_assets + list_font_assets
    end

    def asset_paths
      @asset_paths ||= {
        css: css_asset_paths,
        images: image_asset_paths,
        fonts: font_asset_paths
      }
    end

    def css_asset_paths
      @css_asset_paths ||= list_css_assets.each_with_object({}) do |(prop, asset_path), ret|
        ret[prop] = Mosaico.resolve_asset(asset_path)
      end
    end

    def image_asset_paths
      @image_asset_paths ||= list_image_assets.each_with_object({}) do |asset_path, ret|
        ret[asset_path] = Mosaico.resolve_asset(asset_path)
      end
    end

    def font_asset_paths
      @font_asset_paths ||= list_font_assets.each_with_object({}) do |asset_path, ret|
        ret[asset_path] = Mosaico.resolve_asset(asset_path)
      end
    end

    def resolve_asset(path)
      uri = URI.parse(path)

      [image_asset_paths, font_asset_paths].each do |paths|
        paths.each do |logical_path, digest_path|
          if logical_path.end_with?(uri.path)
            uri.path = digest_path
            return uri.to_s
          end
        end
      end

      nil
    end

    private

    def list_css_assets
      @css_assets ||= CSS_FILES.each_with_object({}) do |(prop, file), ret|
        if exists?(file)
          ret[prop] = File.join(path, file)
        end
      end
    end

    def list_image_assets
      @image_assets ||= Dir.chdir(Mosaico.vendor_asset_root) do
        Dir.glob(File.join(path, 'img', '*.{jpg,gif,png}'))
      end
    end

    def list_font_assets
      @font_assets ||= Dir.chdir(Mosaico.vendor_asset_root) do
        Dir.glob(File.join(path, 'fonts', '*.{eot,svg,ttf,otf,woff,woff2}'))
      end
    end

    def exists?(file)
      File.exist?(File.join(Mosaico.vendor_asset_root, path, file))
    end
  end
end
