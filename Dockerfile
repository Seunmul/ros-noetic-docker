# This is an auto generated Dockerfile for ros:perception
# generated from docker_images/create_ros_image.Dockerfile.em
FROM ubuntu:20.04

LABEL Maintainer="GeonhaPark"

# setup xrdp
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-desktop

RUN rm /run/reboot-required*

RUN useradd -m ubuntu -p $(openssl passwd ubuntu)
RUN usermod -aG sudo ubuntu

RUN apt install -y git wget curl vim net-tools iputils-ping openssh-server
RUN apt install -y xrdp
RUN adduser xrdp ssl-cert

## setup ros

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros1-latest.list

# setup keys
# RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

# setup environment
# ENV LANG C.UTF-8
# ENV LC_ALL C.UTF-8

ENV ROS_DISTRO noetic

# install ros-core packages
RUN apt-get update && apt-get install -y \
    ros-noetic-desktop-full

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    python3-rosdep \
    python3-rosinstall \
    python3-vcstools \
    python3-rosinstall-generator \ 
    python3-wstool \
    build-essential


# bootstrap rosdep
RUN rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO

# start xrdp
RUN sed -i '3 a echo "\
    export GNOME_SHELL_SESSION_MODE=ubuntu\\n\
    export XDG_SESSION_TYPE=x11\\n\
    export XDG_CURRENT_DESKTOP=ubuntu:GNOME\\n\
    export XDG_CONFIG_DIRS=/etc/xdg/xdg-ubuntu:/etc/xdg\\n\
    " > ~/.xsessionrc' /etc/xrdp/startwm.sh

#open ssh server
RUN apt install -y openssh-server

#setup ros-noetic
COPY ./ros_entrypoint.sh /


EXPOSE 22 80 3389


CMD service dbus start; /usr/lib/systemd/systemd-logind & service xrdp start & service ssh start ; bash


#docker run -dit --privileged -v /Users/seunmul/Desktop/docker/kamailio:/share 
#-p 3389:3389 -p 5060:5060/tcp -p 5060:5060/udp -p 5080:5080/tcp -p 5080:5080/udp 
#--name [name] [image] /sbin/init