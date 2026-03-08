cmake_minimum_required(VERSION 3.8)
project(dtc_msgs)

# Default to C++14
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 14)
endif()

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# Find dependencies
find_package(ament_cmake REQUIRED)
find_package(ament_cmake_python REQUIRED)
find_package(std_msgs REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(nav_msgs REQUIRED)
find_package(geometry_msgs REQUIRED)
find_package(rosidl_default_generators REQUIRED)

# Generate messages
rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/NavSatFixArray.msg"
  "msg/NavSatFixTimeAgo.msg"
  "msg/RateTimeAgo.msg"
  "msg/BoolTimeAgo.msg"
  "msg/Uint8TimeAgo.msg"
  "msg/ScoreCard.msg"
  "msg/RespirationRate.msg"
  "msg/HeartRate.msg"
  "msg/GroundDetection.msg"
  "msg/GroundImage.msg"
  "msg/JackalStatus.msg"
  "msg/FalconStatus.msg"
  "msg/CasualtyFix.msg"
  "msg/CasualtyFixArray.msg"
  "msg/ScoreCardString.msg"
  "msg/BoundingBox.msg"
  "msg/CasualtyImage.msg"
  "msg/ReportAndImage.msg"
  "msg/TrackingState.msg"
  "msg/TriageReport.msg"
  "msg/VitalSigns.msg"
  "msg/Gate1.msg"
  "msg/Gate2.msg"
  "msg/Gate3.msg"
  "msg/Gate4.msg"
  DEPENDENCIES
    std_msgs
    sensor_msgs
    nav_msgs
    geometry_msgs
)

ament_package()
