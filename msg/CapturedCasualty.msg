# msg/CapturedCasualty.msg
# One casualty photographed by the arm capture (CaptureCasualty result).
string folder                      # this casualty's capture folder on the robot
string photo                       # primary photo path (empty if none was saved)
geometry_msgs/PointStamped position   # where the casualty is (frame in header)
string lock_src                    # how the target was locked; "none" = no lock, not sent to the VLM
string degraded                    # empty when clean, else why the capture is degraded
string vlm_report                  # VLM report path (empty if not waited for or none arrived)
