FROM ubuntu:xenial

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade
RUN apt-get install -y --no-install-recommends \
        apt-utils \
        libusb-1.0-0-dev \
        udev \
        build-essential \
        cmake \
        sudo \
        git \
        wget \
        python-dev \
        python3-pip \
        python3-dev \
        python-setuptools \
        python3-setuptools \
        usbutils \
        lsb-release \
        libglib2.0-0 libsm6 \
        libfontconfig1  \
        libxrender1  \
        libxtst6 && \
    rm -rf /var/lib/apt/lists/*
RUN apt-get update -qq
RUN apt-get install -y --no-install-recommends libavcodec-ffmpeg-extra56 libswscale-ffmpeg3 python3-pip\
	libavformat-ffmpeg56 libharfbuzz0b libxcb-shm0 libcairo2 libpangoft2-1.0-0 expect cpio vim


WORKDIR /res
# place the openvino toolkit tgz file in the same directory 
COPY l_openvino_toolkit_p_2018.3.343.tgz .
RUN tar -zxf l_openvino_toolkit_p_2018.3.343.tgz 

RUN python3 -m pip install --upgrade pip

# replace this file name with the wheel you want which lies in the same directory.
# COPY tensorflow-1.11.0rc1-cp35-cp35m-linux_x86_64.whl .
# RUN python3 -m pip install tensorflow-1.11.0rc1-cp35-cp35m-linux_x86_64.whl

WORKDIR l_openvino_toolkit_p_2018.3.343
RUN ./install_cv_sdk_dependencies.sh


COPY expecter.sh ./expecter.sh
RUN chmod +x ./expecter.sh
RUN ./expecter.sh

RUN /bin/bash -c "source /opt/intel/computer_vision_sdk/bin/setupvars.sh"


WORKDIR /opt/intel/computer_vision_sdk/deployment_tools/model_optimizer/install_prerequisites
RUN ./install_prerequisites_tf.sh
RUN ./install_prerequisites_caffe.sh

RUN python3 -m pip install keras image opencv-python

WORKDIR /opt/intel/computer_vision_sdk/install_dependencies
RUN ./install_NEO_OCL_driver.sh
RUN usermod -a -G video root

RUN echo "source /opt/intel/computer_vision_sdk/bin/setupvars.sh" >> /root/.bashrc

WORKDIR /


ENTRYPOINT ["bash"]