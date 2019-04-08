module Mosaico
  # Unfortunately the versafix-1 template contains several image assets
  # whose paths contain "google+", which sprockets appears not to like.
  # Rails will refuse to serve these assets, resulting in errors and
  # several broken images on the page. This class fixes the issues by
  # replacing "google+" with "google_plus" and serving renamed assets
  # on-the-fly. It's more complicated, yes, but means the original image
  # and template files don't have to be modified.
  class VersafixTemplate < Template
    private

    def before_register
      google_plus_assets.each do |original_asset_path|
        new_asset_path = original_asset_path.sub('google+', 'google_plus')

        Rails.application.config.assets.generated.add(new_asset_path, precompile: true) do
          File.binread(original_asset_path)
        end
      end

      Rails.application.config.assets.precompile += remaining_assets
    end

    # called by the superclass (i.e. Template) for each URL in the
    # template's HTML code (CSS is handled by css-rewrite in engine.rb)
    def replacement_asset_url(asset_path)
      if found = super
        found.sub('google+', 'google_plus')
      end
    end

    def google_plus_assets
      @google_plus_assets ||= list_assets.grep(/google+/)
    end

    def remaining_assets
      @remaining_assets ||= list_assets - google_plus_assets
    end
  end
end
