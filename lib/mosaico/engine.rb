require 'rails'
require 'generated-assets'
require 'css-rewrite'

module Mosaico
  class Engine < ::Rails::Engine
    isolate_namespace Mosaico

    initializer 'mosaico.assets' do |app|
      app.config.assets.paths << Mosaico.vendor_asset_root.to_s

      ['mosaico/dist/fa', 'mosaico/dist/img'].each do |asset_path|
        config.assets.precompile += Dir.chdir(Mosaico.vendor_asset_root) do
          Dir.glob("#{asset_path}/**/*.*")
        end
      end

      config.assets.precompile << 'mosaico/logo_transparent.png'

      CssRewrite.configure do |config|
        config.rewrite(/\A#{Mosaico.vendor_asset_root.to_s}/) do |url|
          next if url.start_with?('data:')
          asset_path = Mosaico.url_join('mosaico/dist', URI.parse(url).path)

          if resolved_url = Mosaico.resolve_asset(asset_path)
            prefix = Rails.application.config.assets.prefix
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

      Mosaico::Engine.config.placeholder_backend = Mosaico::LocalPlaceholderBackend.new
      Mosaico::Engine.config.image_backend = Mosaico::LocalImageBackend.new
    end
  end
end
