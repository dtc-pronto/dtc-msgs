# DARPA DTC Systems Competition Phase 3 ICD, Rev 1 (February 2026),
# sections 6.6-6.7: initial casualty reports and follow-up assessments
# (printed pages 16-20).
# This is an internal ROS report, not the HTTP JSON body.

# Initial-report category codes. CATEGORY_UNREPORTED is ROS-only and must
# never be submitted to the scoring API; a publisher must explicitly assess
# the casualty before setting category to an ICD value (0-4).
uint8 CATEGORY_URGENT_HEMORRHAGE=0
uint8 CATEGORY_URGENT_AIRWAY=1
uint8 CATEGORY_NON_URGENT_AMBULATORY=2
uint8 CATEGORY_NON_URGENT_STATIONARY=3
uint8 CATEGORY_DECEASED=4
uint8 CATEGORY_UNREPORTED=255

uint8 SECOND_PASS_URGENT=0
uint8 SECOND_PASS_PRIORITY=1
uint8 SECOND_PASS_ROUTINE=2

# Event 3 trauma codes, NOT the legacy ScoreCard enums.
uint8 TRAUMA_AMPUTATION=0
uint8 TRAUMA_OPEN=1
uint8 TRAUMA_CLOSED=2
uint8 TRAUMA_BURN=3

uint8 OCULAR_OPEN=0
uint8 OCULAR_CLOSED=1
uint8 OCULAR_NOT_TESTABLE=2

# Shared codes for verbal and motor alertness.
uint8 ALERTNESS_NORMAL=0
uint8 ALERTNESS_ABNORMAL=1
uint8 ALERTNESS_ABSENT=2
uint8 ALERTNESS_NOT_TESTABLE=3

# ROS-only sentinel: skip this assessment when preparing API requests.
uint8 ASSESSMENT_UNREPORTED=255

# Team-generated casualty ID; the API accepts only 0-99.
uint32 casualty_id
string team
# Registered UxS identifier: at most 10 alphanumeric/underscore characters.
string system

# First-pass category is required by the API; no clinical default is assumed.
uint8 category 255
# Optional API field. Ground floor and exterior ground level are both 1.
uint32 level 1
# Optional API field. Seconds since discovery/first-pass assessment, relative
# to submission time. This is elapsed seconds, NOT a ROS timestamp.
uint32 time_ago 0

# Internal attachment. The API uploads images separately via
# POST /api/casualty_image; image age comes from image.header.stamp.
sensor_msgs/CompressedImage image
# Map gps.latitude / gps.longitude to the API's latitude / longitude fields.
# Validate coordinates before submission. Altitude is not building level and
# is not part of the /api/hmt/casualty JSON body.
sensor_msgs/NavSatFix gps

# Individual observations for POST /api/hmt/assessment. Each populated field
# becomes a separate request: type=field name, value=field value, with this
# report's casualty_id/team/system and the matching <field>_time_ago.
# Value 255 means unreported: skip it and ignore its age. Never treat it as
# normal, zero, or an instruction to erase a previous finding.
# All ages are elapsed seconds relative to submission, independently tracked.

# SECOND_PASS_*: 0 urgent, 1 priority, 2 routine.
uint8 second_pass_category 255
uint32 second_pass_category_time_ago 0

# TRAUMA_*: 0 amputation, 1 open, 2 closed, 3 burn.
uint8 trauma_head 255
uint32 trauma_head_time_ago 0
uint8 trauma_torso_back 255
uint32 trauma_torso_back_time_ago 0
uint8 trauma_torso_front 255
uint32 trauma_torso_front_time_ago 0
uint8 trauma_leg_right 255
uint32 trauma_leg_right_time_ago 0
uint8 trauma_leg_left 255
uint32 trauma_leg_left_time_ago 0
uint8 trauma_arm_right 255
uint32 trauma_arm_right_time_ago 0
uint8 trauma_arm_left 255
uint32 trauma_arm_left_time_ago 0

# OCULAR_*: 0 open, 1 closed, 2 not testable.
uint8 alertness_ocular 255
uint32 alertness_ocular_time_ago 0
# ALERTNESS_*: 0 normal, 1 abnormal, 2 absent, 3 not testable.
uint8 alertness_verbal 255
uint32 alertness_verbal_time_ago 0
# The ICD allowed-type list says alertness_motor; a later explanatory
# heading says alertness_movement. Use the allowed-type spelling.
uint8 alertness_motor 255
uint32 alertness_motor_time_ago 0
