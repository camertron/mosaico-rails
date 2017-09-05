module Mosaico
  module ApplicationHelper
    def translations_include_tag
      javascript_include_tag "mosaico/translations-#{Mosaico.locale}.js"
    end
  end
end
