class Face < ActiveRecord::Base
  belongs_to :photo

  before_destroy :delete_image

  FACE_DIR = Rails.root/"faces"
  FACE_DIR.mkdir unless FACE_DIR.exist?

  def image_path
    path = FACE_DIR/"#{id}.jpg"

    if not path.exist?
      photo.subimage(x, y, width, height).save_image(path.to_s)
    end

    path.to_s
  end

private
  def delete_image
    File.unlink image_path
  end
end
