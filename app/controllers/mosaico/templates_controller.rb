module Mosaico
  class TemplatesController < ::Mosaico::ApplicationController
    def show
      template = Mosaico.find_template(params[:template_name])
      render inline: template.template_content
    end
  end
end
