#!/bin/bash

# Copyright (c) 2018 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

INSTALLDIR=/opt/intel//computer_vision_sdk_2018.5.455
export INTEL_CVSDK_DIR=$INSTALLDIR

# parse command line options
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -pyver)
    python_version=$2
    echo python_version = "${python_version}"
    shift
    ;;
    *)
    # unknown option
    ;;
esac
shift
done

if [ -e $INSTALLDIR/openvx ]; then
    export LD_LIBRARY_PATH=$INSTALLDIR/openvx/lib:$LD_LIBRARY_PATH
fi

if [ -e $INSTALLDIR/deployment_tools/model_optimizer ]; then
    export LD_LIBRARY_PATH=$INSTALLDIR/deployment_tools/model_optimizer/model_optimizer_caffe/bin:$LD_LIBRARY_PATH
    export ModelOptimizer_ROOT_DIR=$INSTALLDIR/deployment_tools/model_optimizer/model_optimizer_caffe
fi

export InferenceEngine_DIR=$INTEL_CVSDK_DIR/deployment_tools/inference_engine/share

if [[ -f /etc/centos-release ]]; then
    if cat /etc/centos-release | grep -q -E "7.4"; then
        IE_PLUGINS_PATH=$INTEL_CVSDK_DIR/deployment_tools/inference_engine/lib/centos_7.4/intel64
    else
        IE_PLUGINS_PATH=$INTEL_CVSDK_DIR/deployment_tools/inference_engine/lib/centos_7.3/intel64
    fi
elif [[ -f /etc/lsb-release ]]; then
     UBUNTU_VERSION=$(lsb_release -r -s)
     if [[ $UBUNTU_VERSION = "16.04" ]]; then
            IE_PLUGINS_PATH=$INTEL_CVSDK_DIR/deployment_tools/inference_engine/lib/ubuntu_16.04/intel64
     elif cat /etc/lsb-release | grep -q "Yocto" ; then
            IE_PLUGINS_PATH=$INTEL_CVSDK_DIR/deployment_tools/inference_engine/lib/ubuntu_16.04/intel64
     fi
fi

if [ -e $INSTALLDIR/deployment_tools/inference_engine ]; then
    export LD_LIBRARY_PATH=/opt/intel/computer_vision_sdk/deployment_tools/inference_engine/lib/ubuntu_18.04/intel64/:/opt/intel/opencl:$INSTALLDIR/deployment_tools/inference_engine/external/cldnn/lib:$INSTALLDIR/deployment_tools/inference_engine/external/gna/lib:$INSTALLDIR/deployment_tools/inference_engine/external/mkltiny_lnx/lib:$IE_PLUGINS_PATH:$LD_LIBRARY_PATH
fi

if [ -e $INSTALLDIR/opencv ]; then
    export OpenCV_DIR=$INSTALLDIR/opencv/share/OpenCV
    export LD_LIBRARY_PATH=$INSTALLDIR/opencv/lib:$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=$INSTALLDIR/opencv/share/OpenCV/3rdparty/lib:$LD_LIBRARY_PATH
fi

export PATH="$INTEL_CVSDK_DIR/deployment_tools/model_optimizer:$PATH"
export PYTHONPATH="$INTEL_CVSDK_DIR/deployment_tools/model_optimizer:$PYTHONPATH"

if [ -z "$python_version" ]; then
    if command -v python3.6 >/dev/null 2>&1; then
        python_version=3.6
    elif command -v python3.5 >/dev/null 2>&1; then
        python_version=3.5
    elif command -v python3.4 >/dev/null 2>&1; then
        python_version=3.4
    elif command -v python2.7 >/dev/null 2>&1; then
        python_version=2.7
    elif command -v python >/dev/null 2>&1; then
        python_version=$(python -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    fi
fi

if [ ! -z "$python_version" ]; then
    if [[ -f /etc/centos-release ]]; then
        if [[ -e $INTEL_CVSDK_DIR/python/python$python_version/centos7 ]]; then
            export PYTHONPATH="$INTEL_CVSDK_DIR/python/python$python_version:$INTEL_CVSDK_DIR/python/python$python_version/centos7:$PYTHONPATH"
        fi
    elif [[ -f /etc/lsb-release ]]; then
        if [[ -e $INTEL_CVSDK_DIR/python/python$python_version/ubuntu16 ]]; then
            export PYTHONPATH="$INTEL_CVSDK_DIR/python/python$python_version:$INTEL_CVSDK_DIR/python/python$python_version/ubuntu16:$PYTHONPATH"
        fi
    fi
fi

echo [setupvars.sh] OpenVINO environment initialized