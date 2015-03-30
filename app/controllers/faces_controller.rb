class FacesController < ApplicationController

  def show
  end

  def image
    @photo = Photo.find params[:photo_id]
    @face = @photo.faces.find params[:id]
    send_file @face.image_path, type: 'image/jpeg', disposition: 'inline'
  end
end
