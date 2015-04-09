# Bugfixes:

* Photo.width/height need to be set *after* scaling

# Requirements:

## Milestone 1:

./ upload photos
./ browse photos

## Milestone 2:

* redetect_faces! in a redirect (/photo/2/redetect => /photo/2/redetecting => /photo/2)
* better region editing
  * (x) z-index above everything else (can't be blocked by other divs)
  * shadows?
  * rubber-band to create new regions
* merge regions that are on top of each other
  * distance metric (sum of corner distances?)
  * merge: mean of corners

* upload photos without an account
  * photo has a hard-to-guess URL
  * all photos are stored in the user's session
  * if user creates an account, the photos are placed in their account
