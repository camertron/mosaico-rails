require 'rails'
require 'generated-assets'
require 'css-rewrite'

module Mosaico
  class Engine < ::Rails::Engine
    isolate_namespace Mosaico

    initializer 'mosaico.assets' do |app|
      app.config.assets.paths << Mosaico.vendor_asset_root.to_s

      # fonts and images
      ['mosaico/dist/fa', 'mosaico/dist/img'].each do |asset_path|
        config.assets.precompile += Dir.chdir(Mosaico.vendor_asset_root) do
          Dir.glob("#{asset_path}/**/*.*")
        end
      end

      # plugins
      config.assets.precompile += Dir.chdir(Mosaico.vendor_asset_root) do
        Dir.glob('mosaico/dist/vendor/plugins/*/plugin.js')
      end

      # themes
      config.assets.precompile += Dir.chdir(Mosaico.vendor_asset_root) do
        Dir.glob('mosaico/dist/vendor/themes/*/theme.js')
      end

      # skins
      config.assets.precompile += Mosaico.mce_skins.flat_map do |_, skin|
        skin.list_precompile_assets
      end

      config.assets.precompile << 'mosaico/logo_transparent.png'

      CssRewrite.configure do |config|
        prefix = Rails.application.config.assets.prefix

        Mosaico.mce_skins.each do |skin_name, skin|
          config.rewrite(/\A#{skin.absolute_path}/) do |url|
            next if url.start_with?('data:')

            if resolved_url = skin.resolve_asset(url)
              Mosaico.url_join(prefix, resolved_url)
            end
          end
        end

        config.rewrite(/\A#{Mosaico.vendor_asset_root.to_s}/) do |url|
          next if url.start_with?('data:')
          asset_path = Mosaico.url_join('mosaico/dist', URI.parse(url).path)

          if resolved_url = Mosaico.resolve_asset(asset_path)
            Mosaico.url_join(prefix, resolved_url)
          end
        end
      end

      Mosaico.available_locales.each do |locale|
        asset_path = "mosaico/translations-#{locale}.js"

        app.config.assets.generated.add(asset_path, precompile: true) do
          locale_path = Mosaico.vendor_lang_root.join("mosaico-#{locale}.json")

          "window.mosaico = window.mosaico || {};\n" +
            "window.mosaico.translations = #{File.read(locale_path)};"
        end
      end

      Mosaico.locale = I18n.default_locale
    end

    # https://content.pivotal.io/blog/leave-your-migrations-in-your-rails-engines
    initializer 'mosaico.append_migrations' do |app|
      unless app.root.to_s.match(root.to_s)
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end

    initializer 'mosaico.default_config' do |app|
      TEMPLATE_CLASSES = {
        'versafix-1' => Mosaico::VersafixTemplate
      }

      %w(tedc15 tutorial versafix-1).each do |template|
        Mosaico.register_template(
          template,
          Mosaico.vendor_template_root.join(template).to_s,
          template_class: TEMPLATE_CLASSES.fetch(template, Mosaico::Template)
        )
      end

      Mosaico::Engine.config.placeholder_backend = nil
      Mosaico::Engine.config.image_backend = nil

      config.after_initialize do
        Mosaico::Engine.config.placeholder_backend ||= Mosaico::ActiveStoragePlaceholderBackend.new
        Mosaico::Engine.config.image_backend = Mosaico::ActiveStorageImageBackend.new
      end
    end
  end
end
