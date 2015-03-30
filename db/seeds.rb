# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.create(email: "chris@ill-logic.com", password: "test", password_confirmation: "test")

class Pathname
  def original_filename
    basename
  end
end

Pathname.new("examples").children.each do |file|
  p file
  user.photos.create(image_file: file)
end
