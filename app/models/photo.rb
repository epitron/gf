class Photo < ActiveRecord::Base

  MAX_RESOLUTION = 2000
  THUMB_RESOLUTION = 200

  has_many :faces, dependent: :destroy
  belongs_to :user

  validate        :ensure_valid_image
  before_save     :set_dimensions
  after_save      :write_image
  after_save      :redetect_faces!
  before_destroy  :remove_file

  def image_file=(file)
    self.filename = file.original_filename
    @image        = OpenCV::CvMat.decode(file.read)
  end

  def image
    @image ||= OpenCV::CvMat.load(absolute_path)
  end

  def absolute_path
    (upload_dir / "#{id}.jpg").to_s
  end

  def thumb_path
    (upload_dir / "#{id}.thumb.jpg").to_s
  end

  def redetect_faces!
    faces.destroy_all
    regions = detect_face_regions
    p regions
    faces.create(regions)
  end

private

  def upload_dir
    Rails.root / "uploads"
  end

  def set_dimensions
    self.width  ||= image.width
    self.height ||= image.height
  end

  def ensure_valid_image
    @image.dims
  rescue OpenCV::CvStsBadArg
    errors.add(:image_file, "must be a valid JPEG or a PNG file")
  end

  def resized(max_resolution)
    if image.width > max_resolution or image.height > max_resolution
      aspect = image.width.to_f / image.height

      newsize = if aspect > 1
        OpenCV::CvSize.new(max_resolution, max_resolution / aspect)
      else
        OpenCV::CvSize.new(max_resolution * aspect, max_resolution)
      end

      image.resize(newsize)
    else
      image
    end
  end

  def detect_face_regions
    regions = FACE_CLASSIFIERS.map do |classifier|
      classifier.detect_objects(image).to_a
    end.flatten

    regions.map do |region|
      {x: region.x, y: region.y, width: region.width, height: region.height}
    end
  end

  def write_image
    # make upload directory
    upload_dir.mkdir unless upload_dir.exist?

    # generate file and thumb
    resized(MAX_RESOLUTION).save_image(absolute_path) unless File.exists? absolute_path
    resized(THUMB_RESOLUTION).save_image(thumb_path) unless File.exists? thumb_path
  end

  def remove_file
    File.unlink(absolute_path) if File.exists? absolute_path
  end

end
