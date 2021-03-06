class PhotosController < ApplicationController

  before_filter :require_login, except: [:index]

  # show current_user's photos
  def index
    if current_user
      @photos = current_user.photos
    else
      redirect_to login_path
    end
  end

  # upload form
  def new
    @photo = Photo.new
  end

  # upload photo
  def create
    @photo = Photo.new(photo_params)
    @photo.user = current_user

    if @photo.save
      redirect_to @photo
    else
      render "new"
    end
  end


  before_filter :load_photo, except: [:index, :new, :create]

  def show
    @median_width, @median_height = @photo.median_face_size
  end

  def edit
  end

  def update
    if @photo.update_attributes(photo_params)
      redirect_to @photo
    else
      render "edit"
    end
  end

  def full
    send_file @photo.absolute_path, type: 'image/jpeg', disposition: 'inline'
  end

  def thumb
    send_file @photo.thumb_path, type: 'image/jpeg', disposition: 'inline'
  end

  def redetect
    @photo.redetect_faces!
    redirect_to @photo
  end

private

  def photo_params
    params.require(:photo).permit(:image_file, :faces_attributes => [:id, :name, :description])
  end

  def load_photo
    @photo = Photo.find params[:id]
  end    

end
