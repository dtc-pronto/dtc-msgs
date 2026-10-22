# DTC Msgs

This repo should contain any custom message types used for the DTC project. This will make `MOCHA` configuration significantly easier. 

## Parser 
I wrote a python parser for the `ScoreCard` to conver it to a dict. I still need to implement the time conversion but I'm not sure what format DARPA wants. Here is the usage:
```
from dtc_msgs.msg import ScoreCard
from dtc_msgs.scorecard_parser import ScoreCardParser

msg = ScoreCard()
d = ScoreCardParser.parse_to_dict(msg)
```

## Message Definitions

### Gate1, Gate2, Gate3, Gate4, and HMT

Each message includes a compressed image and a GPS fix:

```text
sensor_msgs/CompressedImage image
sensor_msgs/NavSatFix gps
```

`gps.latitude` and `gps.longitude` are in degrees, and `gps.altitude` is in meters
above the WGS 84 ellipsoid. Gate1 also retains its existing `latitude` and
`longitude` fields; publishers should keep them consistent with `gps`.

### HMT (Event 3 ICD)

Based on **DARPA DTC Interface Control Document Systems Competition Phase 3,
Revision 1, February 2026**, sections 6.6 (printed pages 16-17), 6.7 (18-20), and
6.10 (23-24). `HMT` is an internal ROS report: it carries an initial casualty
observation, optional follow-up assessments, and optional image data. It is not
itself the HTTP JSON body, and this package does not implement an API sender.

Its data fields are:

```text
uint32 casualty_id
string team
string system
uint8 category 255
uint32 level 1
uint32 time_ago 0
sensor_msgs/CompressedImage image
sensor_msgs/NavSatFix gps

uint8 second_pass_category 255
uint32 second_pass_category_time_ago 0
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
uint8 alertness_ocular 255
uint32 alertness_ocular_time_ago 0
uint8 alertness_verbal 255
uint32 alertness_verbal_time_ago 0
uint8 alertness_motor 255
uint32 alertness_motor_time_ago 0
```

#### Initial report: POST /api/hmt/casualty

| API field | ROS field | ICD constraint |
|---|---|---|
| `casualty_id` | `casualty_id` | Required, integer 0-99 |
| `team` | `team` | Required team identifier |
| `system` | `system` | Required registered UxS identifier; up to 10 alphanumeric/underscore characters |
| `latitude` | `gps.latitude` | Required, degrees from -90 to 90 |
| `longitude` | `gps.longitude` | Required, degrees from -180 to 180 |
| `category` | `category` | Required, first-pass category 0-4 |
| `level` | `level` | Optional, non-negative integer; default 1 (ground floor/exterior) |
| `time_ago` | `time_ago` | Optional, non-negative elapsed seconds since discovery/first-pass assessment; default 0 |

First-pass codes are **0 urgent/hemorrhage, 1 urgent/airway, 2 non-urgent/ambulatory,
3 non-urgent/stationary, 4 deceased**. Named `CATEGORY_*` constants are provided.
The ROS-only default **255 means unreported**, not an ICD category. An API sender
must reject that value instead of treating an unassessed casualty as category 0.
`gps` is the single source of coordinates; do not duplicate latitude/longitude
fields. Altitude is not building level and is not sent to this endpoint.

#### Follow-up: POST /api/hmt/assessment

Assessments are **individual named scalar fields directly on HMT**, not a list
or a nested message. Each has a `uint8` value (default 255) and a matching
`uint32 <field>_time_ago` (default 0). For each reported value, send a separate
request with `type` equal to the field name, `value` equal to its value, and
`time_ago` from its matching age field, attaching `casualty_id`, `team`, and
`system` from HMT. For example, `trauma_head=HMT.TRAUMA_OPEN` and
`trauma_head_time_ago=5` map to `type="trauma_head", value=1, time_ago=5`.
Do not automatically
re-submit an initial casualty report for every follow-up message: the ICD rejects
duplicate initial IDs within a run. **Skip fields whose value is 255** and ignore
their age fields; an unreported assessment must not produce a zero-valued
finding or erase a previously received finding. Each field holds one observation;
publish another HMT message to update it.

| Assessment `type` | Valid `value` codes |
|---|---|
| `second_pass_category` | 0 urgent, 1 priority, 2 routine |
| `trauma_head`, `trauma_torso_back`, `trauma_torso_front`, `trauma_leg_right`, `trauma_leg_left`, `trauma_arm_right`, `trauma_arm_left` | 0 amputation, 1 open, 2 closed, 3 burn |
| `alertness_ocular` | 0 open, 1 closed, 2 not testable |
| `alertness_verbal`, `alertness_motor` | 0 normal, 1 abnormal, 2 absent, 3 not testable |

`HMT` provides `SECOND_PASS_*`, `TRAUMA_*`, `OCULAR_*`, `ALERTNESS_*`, and
`ASSESSMENT_UNREPORTED` constants. The default value 255 is ROS-only and must
not be sent to the API. **Do not reuse the legacy ScoreCard
trauma codes.** The ICD lists `alertness_motor` as an accepted type but uses
`alertness_movement` in a later explanatory heading; this schema follows the
accepted-type list and uses `alertness_motor`.

`time_ago` is elapsed integer seconds, not `builtin_interfaces/Time` or an epoch
timestamp. Each assessment has its own age. A delayed sender must account for
transport/queueing time when preparing the HTTP request. ROS field types do not
enforce ICD ranges or identifier syntax; validate all values at the API boundary.
HMT does not include `hr`/`rr`: the ICD defines those under Gate 4's `/api/vitals`,
not either HMT report endpoint.

#### Images and migration

Keep `image` as `sensor_msgs/CompressedImage` for ROS/ATAK use. The scoring API
requires a separate multipart `/api/casualty_image` upload, PNG/JPEG, no larger
than 5 MB and at most 1 Hz. Compute its age from the image capture timestamp
(`image.header.stamp`), not automatically from the casualty's `time_ago`; publishers
must populate that timestamp when providing an image.

This is a **wire-format change**. Rebuild and restart all publishers/subscribers
with the same message revision. The existing `casualty_id`, `team`, `system`,
`gps`, and `image` fields are retained. No other Gate message is changed here.
If you built the earlier list-based draft, use a fresh build/install space to
avoid retaining the removed generated assessment helper. All assessment fields
and constants now belong to `HMT` itself.

After building this package and sourcing its install space, run the schema checks:

```bash
python3 -m pytest test/test_hmt_icd.py -q
```

### ScoreCard
This uses the exact layout of the scorecard from DARPA
```
std_msgs/Header header

uint32 casualty_id

dtc_msgs/NavSatFixTimeAgo location

dtc_msgs/BoolTimeAgo severe_hemorrhage
dtc_msgs/BoolTimeAgo respiratory_distress

dtc_msgs/RateTimeAgo heart_rate
dtc_msgs/RateTimeAgo respiratory_rate

# 0 => Normal, 1 => Wound, 2 => Not Testable (NT)
dtc_msgs/Uint8TimeAgo trauma_head
# 0 => Normal, 1 => Wound, 2 => Not Testable (NT)
dtc_msgs/Uint8TimeAgo trauma_torso
# 0 => Normal, 1 => Wound, 2 => Amputation, 3 => NT
dtc_msgs/Uint8TimeAgo trauma_upper_extremity
# 0 => Normal, 1 => Wound, 2 => Amputation, 3 => NT
dtc_msgs/Uint8TimeAgo trauma_lower_extremity

# 0 => Open, 1 => Closed, 2 => NT
dtc_msgs/Uint8TimeAgo alertness_ocular
# 0 => Normal, 1 => Abnormal, 2 => Absent, 3 => NT
dtc_msgs/Uint8TimeAgo alterness_verbal
# 0 => Normal, 1 => Abnormal, 2 => Absent, 3 => NT
dtc_msgs/Uint8TimeAgo alterness_motor
```
### BoolTimeAgo
```
bool value
std_msgs/Time time_ago
```
### RateTimeAgo
```
float64 value
std_msgs/Time time_ago
```
### Uint8TimeAgo
```
uint8 value
std_msgs/Time time_ago
```
### NavSatFixTimeAgo
```
sensor_msgs/NavSatFix location
std_msgs/Time time_ago
```
### NavSatFixArray
```
std_msgs/Header header
sensor_msgs/NavSatFix[] coordinates
```
### RespirationRate
```
std_msgs/Header header
std_msgs/UInt64 casualty_id
std_msgs/Float64 rate
```
### HeartRate
```
std_msgs/Header header
std_msgs/UInt64 casualty_id
std_msgs/Float64 rate
```
### JackalStatus
```
std_msgs/Header header

# 0 is not running, 1 is running
bool controller
bool rgb
bool thermal
bool ouster
bool gps
bool rtk
bool radar
```
### FalconStatus
```
std_msgs/Header header

# 0 is not running, 1 is running
bool rgb
bool thermal
bool gps
bool rtk
```
### GroundDetection
```
std_msgs/Header header

sensor_msgs/NavSatFix gps

std_msgs/UInt64 casualty_id

std_msgs/String whisper

dtc_msgs/RespirationRate acconeer
dtc_msgs/RespirationRate mtts_resp

dtc_msgs/HeartRate mtts_hr
```
### GroundImage
```
std_msgs/Header header

sensor_msgs/NavSatFix gps

sensor_msgs/CompressedImage image1
sensor_msgs/CompressedImage image2
sensor_msgs/CompressedImage image3

std_msgs/UInt64 casualty_id
```
