FACE_CLASSIFIERS = (Rails.root/"haar-xml").children.map do |path|
# FACE_CLASSIFIERS = [Rails.root/"haar-xml/frontal.xml"].map do |path|
# FACE_CLASSIFIERS = [Rails.root/"haar-xml/profile.xml"].map do |path|
  OpenCV::CvHaarClassifierCascade::load path.to_s
end
