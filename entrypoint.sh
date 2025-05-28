#!/bin/bash
set -e

# Source ROS and build workspace
source /opt/ros/noetic/setup.bash
cd ${CATKIN_WS}
source devel/setup.bash

# Launch the tortoisebot in gazebo simulation
roslaunch tortoisebot_gazebo tortoisebot_playground.launch &

# Wait for ROS master to be available
echo "Waiting for ROS master at $ROS_MASTER_URI..."
until rostopic list > /dev/null 2>&1; do
    sleep 1
done
echo "ROS master is ready!"

# Launch the Waypoints Action Server for ROS1
cd ~/simulation_ws && catkin_make && source devel/setup.bash
rosrun tortoisebot_waypoints tortoisebot_action_server.py

# Execute the command passed to docker run
exec "$@"
