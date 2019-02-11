require 'mini_magick'

module Mosaico
  class ImagesController < ::Mosaico::ApplicationController
    def create
      files = params[:files].map do |file|
        dest_file = File.basename(file.tempfile.path)
        UploadedImage.backend.store(file.tempfile.path, as: dest_file)
        image = MiniMagick::Image.new(file.tempfile.path)

        record = UploadedImage.create!(
          file: dest_file,
          width: image[:width],
          height: image[:height],
          filesize: File.size(file.path),
          mime_type: MIME::Types.type_for(image.path).first.to_s
        )

        record.to_json
      end

      render json: { files: files }
    end

    def show
      case params[:method]
        when 'placeholder'
          placeholder = find_or_create_placeholder(*params[:params].split(','))
          send_image(placeholder)

        when 'resize', 'cover'
          original_image = UploadedImage.find(id_from_params)
          width, height = params[:params].split(',')
          width = original_image.width if width == 'null'
          height = original_image.height if height == 'null'
          width = width.to_i
          height = height.to_i

          image = UploadedImage.where(parent_id: id_from_params, width: width, height: height).first
          send_image(image) and return if image

          image_path = UploadedImage.backend.retrieve(original_image.file)
          resized_image = MiniMagick::Image.open(image_path)

          if params[:method] == 'resize'
            resized_image.combine_options do |c|
              c.resize("#{width}x#{height}")
              c.antialias
            end
          else
            resized_image.combine_options do |c|
              c.resize("#{width}x#{height}^")
              c.gravity(:center)
              c.extent("#{width}x#{height}>")
              c.antialias
            end
          end

          dest_file = File.basename(resized_image.path)
          UploadedImage.backend.store(resized_image.path, as: dest_file)

          resized_record = UploadedImage.create!(
            file: dest_file,
            width: width,
            height: height,
            filesize: File.size(resized_image.path),
            mime_type: MIME::Types.type_for(resized_image.path).first.to_s,
            parent_id: original_image.id
          )

          send_image(resized_record)

        else
          if id_from_params
            image = UploadedImage.find(id_from_params)
            send_image(image)
          else
            render json: { files: UploadedImage.where(parent_id: nil).map(&:to_json) }
          end
      end
    end

    def destroy
      UploadedImage.find(id_from_params).destroy
      head :ok
    end

    private

    # this is awful and it's all mosaico's fault, baah
    def id_from_params
      params.fetch(:id) do
        if params[:src]
          host_app_route = Rails.application.routes.routes.find do |r|
            r.path.to_regexp =~ params[:src]
          end

          match = host_app_route.path.to_regexp.match(params[:src])
          start = match[0].size

          Mosaico::Engine.routes.recognize_path(params[:src][start..-1])[:id]
        end
      end
    end

    def send_image(image)
      image_url = image.class.backend.url_to(image.file)
      redirect_to image_url
    end

    def find_or_create_placeholder(width, height)
      image = PlaceholderImage.where(width: width, height: height).first
      return image if image

      image = MiniMagick::Image.open(placeholder_seed)

      image.combine_options do |c|
        c.resize("#{width}x#{height}!")
        c.gravity('Center')
        c.font(File.join(Mosaico.vendor_font_root, 'LiberationSans-Regular.ttf'))
        c.pointsize(width.to_i * height.to_i * 0.001)
        c.draw("text 0,0 '#{width}x#{height}'")
        c.border(1)
      end

      file = "#{width}x#{height}#{File.extname(image.path)}"
      PlaceholderImage.backend.store(image.path, as: file)

      PlaceholderImage.create!(
        file: file,
        width: width,
        height: height,
        filesize: File.size(image.path),
        mime_type: MIME::Types.type_for(image.path).first.to_s
      )
    end

    def placeholder_seed
      Mosaico::Engine.root.join('lib', 'mosaico', 'placeholder.png').to_s
    end
  end
end
