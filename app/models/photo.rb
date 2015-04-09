module Enumerable
  def median
    sorted = sort
    len = sorted.length
    return (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
  end
end

class OpenCV::CvAvgComp

  def inspect
    "#<Region @ (#{x},#{y})-#{width}x#{height}>"
  end
end

class Photo < ActiveRecord::Base

  MAX_RESOLUTION = 2000
  THUMB_RESOLUTION = 200

  UPLOAD_DIR = Rails.root / "uploads"
  UPLOAD_DIR.mkdir unless UPLOAD_DIR.exist?


  has_many :faces, dependent: :destroy
  belongs_to :user

  accepts_nested_attributes_for :faces

  validate        :ensure_valid_image
  before_save     :set_dimensions
  after_save      :write_image
  before_destroy  :remove_file

  def image_file=(file)
    self.filename = file.original_filename
    @image        = OpenCV::CvMat.decode(file.read)
  end

  def image
    @image ||= OpenCV::CvMat.load(absolute_path)
  end

  def absolute_path
    (UPLOAD_DIR / "#{id}.jpg").to_s
  end

  def thumb_path
    (UPLOAD_DIR / "#{id}.thumb.jpg").to_s
  end

  def redetect_faces!
    faces.destroy_all
    regions = detect_face_regions
    p regions
    faces.create(regions)
  end

  def subimage(*slice)
    image.subrect(*slice)
  end

  def median_face_size
    [faces.map(&:width).median, faces.map(&:height).median]
  end

private

  def set_dimensions
    self.width  ||= image.width
    self.height ||= image.height
  end

  def ensure_valid_image
    File.exists?(absolute_path) or (@image && @image.dims)
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

  def filter_regions(rs)
    # step 1: remove regions that are way too big and contain other regions
    # step 2: remove overlapping regions

    rs.combination(2).map do |r0, r1|
      # algorithm: http://jsfiddle.net/uthyZ/

      x11 = r0.x
      y11 = r0.y
      x12 = r0.x + r0.width
      y12 = r0.y + r0.height
      x21 = r1.x
      y21 = r1.y
      x22 = r1.x + r1.width
      y22 = r1.y + r1.height

      inner_left   = [x11,x21].max
      inner_right  = [x12,x22].min
      inner_top    = [y11,y21].max
      inner_bottom = [y12,y22].min

      x_overlap = [ 0, inner_right - inner_left ].max
      y_overlap = [ 0, inner_bottom - inner_top ].max

      overlap = x_overlap * y_overlap

      overlap > 0 ? [r0, r1, overlap] : nil
    end.compact
  end

  def detect_face_regions
    regions = FACE_CLASSIFIERS.map do |classifier|
      classifier.detect_objects(image).to_a
    end.flatten

    p filtered: filter_regions(regions)

    regions.map do |region|
      {x: region.x, y: region.y, width: region.width, height: region.height}
    end
  end

  def write_image
    # make upload directory

    # generate file and thumb
    resized(MAX_RESOLUTION).save_image(absolute_path) unless File.exists? absolute_path
    resized(THUMB_RESOLUTION).save_image(thumb_path)  unless File.exists? thumb_path
  end

  def remove_file
    File.unlink(absolute_path) if File.exists? absolute_path
  end

end
