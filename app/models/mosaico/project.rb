module Mosaico
  # a project is created from a mosaico template
  class Project < ActiveRecord::Base
    def template
      @template ||= Mosaico.find_template(template_name)
    end

    def template=(new_template)
      template_name = new_template.name
      @template = new_template
    end
  end
end
