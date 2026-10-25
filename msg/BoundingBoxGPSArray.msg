# Original image acquisition stamp and physical camera frame ID.
std_msgs/Header header
# One entry per valid image box, including unidentified people and no-fix boxes.
dtc_msgs/BoundingBoxGPS[] detections
