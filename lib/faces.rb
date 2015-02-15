require 'epitools'
require 'opencv'
include OpenCV

COLORS = [
  # CvColor::Blue,
  CvColor::Aqua,
  CvColor::Red,
  CvColor::Green, 
  CvColor::Purple, 
  CvColor::Yellow,
]

# ------------------
# TODO:
# ------------------
#
# Cleanup regions:
#   - merge overlapping regions
#   - delete a big region that has many small regions in it
#

class Faces

  MAX_RESOLUTION = 2000

  attr_accessor :detectors

  def initialize
    @detectors = Path["xml/*.xml"].map do |xml|
      detector = time("load #{xml}") { CvHaarClassifierCascade::load(xml) }
      [xml.basename, detector]
    end.to_h
  end

  def detect(image)
    detected = detectors.map do |name, detector|
      [name, time("detect #{name}") { detector.detect_objects(image) }]
    end.to_h

    p detected

    detected
  end

  def detect_file(filename)
    image = time("loaded #{filename}") { CvMat.load(filename) }
    detect(image)
  end

  def detect_and_annotate(filename)
    image    = load_image(filename)
    detected = detect(image)

    annotate!(image, detected)

    image
  end

  def display_annotated(filename)
    image  = detect_and_annotate(filename)
    window = GUI::Window.new(filename)

    window.show(image)
    pause
    window.destroy
  end

private

  def annotate!(image, detected)
    font = CvFont.new(:simplex) # CvFont.new(:simplex, :hscale => 2, :vslace => 2, :italic => true)

    detected.each_with_index do |(name, regions), i|
      color = COLORS[i]

      ypos = (i * 20) + 30
      xpos = 10

      image.put_text!(name, CvPoint.new(xpos, ypos), font, color)

      regions.each do |region|
        image.rectangle! region.top_left, region.bottom_right, :color => color
      end
    end

    image
  end

  def load_image(filename)
    image = time("loaded #{filename}") { CvMat.load(filename) }
    resize(image)
  end

  def resize(image)
    s = image.size

    if s.width > MAX_RESOLUTION or s.height > MAX_RESOLUTION
      aspect = s.width.to_f / s.height

      newsize = if aspect > 1
        CvSize.new(MAX_RESOLUTION, MAX_RESOLUTION / aspect)
      else
        CvSize.new(MAX_RESOLUTION * aspect, MAX_RESOLUTION)
      end

      time("resized #{image}") { image.resize(newsize) }
    else
      image
    end
  end

  KEY_SPACE = 1048608
  KEY_Q     = 1048689

  def pause
    loop do
      case GUI::wait_key
      when KEY_Q
        exit
      when KEY_SPACE
        break
      end
    end
  end
end


args  = ARGV

if args.empty?
  puts "Usage: ruby #{__FILE__} <image files...>"
  exit 1
end

faces = Faces.new

args.each do |arg|
  puts "=================== #{arg} ======================"
  begin
    faces.display_annotated(arg)
  rescue StandardError => e
    p e
  end
end


