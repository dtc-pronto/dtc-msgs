# msg/TrackingState.msg

sensor_msgs/Image image_annotated
sensor_msgs/Image image_nostrils
std_msgs/Bool tracking_stable
std_msgs/String pose_type

geometry_msgs/Point[] landmarks
std_msgs/Float32 subject_motion
dtc_msgs/BoundingBox body_box
