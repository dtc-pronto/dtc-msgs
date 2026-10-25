# Detection stamp; frame_id retains the legacy optional person ID.
std_msgs/Header header
# Fleet-wide graph target ID (PersonDetection.person_id) as a string; empty means unidentified ("0" is valid).
string id
# Clipped source-image box, in pixels, identical to the original box output.
vision_msgs/BoundingBox2D bbox
# Ground projections of the IMAGE box corners, not the full image footprint.
# All fixes carry the source image header. Unknown altitude is NaN.
# Invalid projection: STATUS_NO_FIX and NaN latitude/longitude for all corners and the centroid.
sensor_msgs/NavSatFix upper_left
sensor_msgs/NavSatFix upper_right
sensor_msgs/NavSatFix lower_right
sensor_msgs/NavSatFix lower_left
# Ground projection of bbox.center (not the average of the GPS corners).
sensor_msgs/NavSatFix centroid
# Empty on success; machine-readable reason when GPS is unavailable.
string localization_error
