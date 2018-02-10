module Mosaico
  class VersafixTemplate < Template
    private

    def before_register
      google_plus_assets.each do |original_asset_path|
        relative_original_asset_path = original_asset_path.sub(/\A#{Mosaico.vendor_asset_root}\//, '')
        relative_new_asset_path = relative_original_asset_path.sub('google+', 'google_plus')

        Rails.application.config.assets.generated.add(relative_new_asset_path, precompile: true) do
          File.binread(original_asset_path)
        end
      end

      Rails.application.config.assets.precompile += remaining_assets
    end

    def replacement_asset_url(asset_path)
      super.tap do |replacement_path|
        if google_plus_assets.include?(asset_path)
          replacement_path.sub!('google+', 'google_plus')
        end
      end
    end

    def google_plus_assets
      @google_plus_assets ||= list_precomp_assets.grep(/google+/)
    end

    def remaining_assets
      @remaining_assets ||= list_precomp_assets - google_plus_assets
    end
  end
end
