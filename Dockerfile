FROM osrf/ros:noetic-desktop-full

# ===== User Setup =====
ARG USERNAME=ttbot
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV DEBIAN_FRONTEND=noninteractive
ENV CATKIN_WS=/home/${USERNAME}/simulation_ws

# Tell the container to use the C.UTF-8 locale for its language settings
ENV LANG C.UTF-8
SHELL ["/bin/bash", "-c"]

# ===== System Dependencies =====
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && chown -R ${USER_UID}:${USER_GID} /home/${USERNAME} \
    && mkdir -p ${CATKIN_WS} \
    && chown -R ${USERNAME}:${USERNAME} ${CATKIN_WS} \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        python3-rosdep \
        python3-catkin-tools \
        python3-pip \
        python3-lxml \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && rm -rf /var/lib/apt/lists/*

# ===== Python Configuration =====
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# ===== ROS/Gazebo Dependencies =====
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gazebo11 \
        ros-noetic-gazebo-ros-pkgs \
        ros-noetic-gazebo-ros-control \
    && rm -rf /var/lib/apt/lists/*

# ===== User Context + Workspace Setup =====
USER ${USERNAME}
WORKDIR ${CATKIN_WS}

# ===== Copy and Build =====
RUN mkdir src
RUN git clone -b noetic https://github.com/rigbetellabs/tortoisebot.git src/tortoisebot
RUN git clone https://github.com/kailash197/cp23_ros1test_tortoisebot_waypoints.git src/tortoisebot_waypoints
RUN source /opt/ros/noetic/setup.bash \
    && catkin_make \
    && source devel/setup.bash \
    && echo "source /opt/ros/noetic/setup.bash" >> /home/${USERNAME}/.bashrc \
    && echo "source ${CATKIN_WS}/devel/setup.bash" >> /home/${USERNAME}/.bashrc

# ===== Environment Variables =====
ENV ROS_DISTRO=noetic
ENV ROS_MASTER_URI=http://gazebo_container:11311
ENV ROS_HOSTNAME=gazebo_container
ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"

# ===== Cleanup =====
RUN sudo rm -rf /root/.cache

# ===== Entrypoint =====
COPY --chown=${USER_UID}:${USER_GID} ./ros1_ci/entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
