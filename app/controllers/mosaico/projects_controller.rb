module Mosaico
  class ProjectsController < ApplicationController
    layout 'mosaico/application'

    def new
      template = Mosaico.find_template(params[:template_name])
      @project = Project.new.tap { |proj| proj.template = template }
    end

    def create
      project = Mosaico::Project.create(project_params)
      render json: { project_id: project.id }, status: :created
    end

    def update
      project = Mosaico::Project.find(params[:id])
      project.update_attributes(project_params)
      render json: { project_id: project.id }, status: :ok
    end

    def show
      @project = Mosaico::Project.find(params[:id])
    end

    private

    def project_params
      params.permit(:metadata, :content, :html, :template_name)
    end
  end
end
