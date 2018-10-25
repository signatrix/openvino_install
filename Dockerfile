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
# RUN sudo apt install -y software-properties-common
# RUN sudo add-apt-repository -y ppa:jonathonf/python-3.6
RUN apt-get update -qq
RUN apt-get install -y --no-install-recommends libavcodec-ffmpeg-extra56 libswscale-ffmpeg3 python3-pip\
	libavformat-ffmpeg56 libharfbuzz0b libxcb-shm0 libcairo2 libpangoft2-1.0-0 expect cpio

WORKDIR /res
COPY l_openvino_toolkit_p_2018.3.343.tgz .
RUN tar -zxf l_openvino_toolkit_p_2018.3.343.tgz 

COPY tensorflow-1.12.0rc0-cp36-cp36m-linux_x86_64.whl .
RUN python3 -m pip install tensorflow-1.11.0rc0-cp35-cp35m-linux_x86_64.whl

# to install from a predefined wheel stored officially use this command instead of the two lines above
# RUN python3 -m pip install https://storage.googleapis.com/intel-optimized-tensorflow/tensorflow-1.11.0-cp35-cp35m-linux_x86_64.whl

WORKDIR l_openvino_toolkit_p_2018.3.343
RUN ./install_cv_sdk_dependencies.sh


COPY expecter.sh ./expecter.sh
RUN chmod +x ./expecter.sh
RUN ./expecter.sh

RUN /bin/bash -c "source /opt/intel/computer_vision_sdk/bin/setupvars.sh"


WORKDIR /opt/intel/computer_vision_sdk/deployment_tools/model_optimizer/install_prerequisites
RUN ./install_prerequisites_tf.sh
# RUN ./install_prerequisites_caffe.sh

WORKDIR /


ENTRYPOINT [ "bash" ]