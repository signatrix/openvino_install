#!/bin/bash

echo "extracting toolkit"

sudo apt -y install expect

sudo rm -r /opt/intel

tar -zxf l_openvino_toolkit_p_2019.3.376.tgz
cd l_openvino_toolkit_p_2019.3.376
cp ../expecter.sh ./expecter.sh

# cp ../patch/install_cv_sdk_dependencies.sh install_cv_sdk_dependencies.sh

echo "installing dependencies"
sudo -E ./install_openvino_dependencies.sh

echo "installing toolkit"
./expecter.sh

# echo "patching version"
# cp ../patch/install_NEO_OCL_driver.sh /opt/intel/computer_vision_sdk/install_dependencies/install_NEO_OCL_driver.sh
# cp ../patch/InferenceEngineConfig.cmake /opt/intel/computer_vision_sdk/deployment_tools/inference_engine/share/InferenceEngineConfig.cmake
# cp ../patch/CMakeLists.txt /opt/intel/computer_vision_sdk/deployment_tools/inference_engine/samples/CMakeLists.txt

echo "setting up environment variables. Adding to zshrc"
cd /opt/intel/openvino
source bin/setupvars.sh
if [ -d "/home/cw" ]; then
  echo 'source /opt/intel/computer_vision_sdk/bin/setupvars.sh' >> /home/cw/.zshrc
else
  echo "Please create /home/cw user and add setupvars to rc script."
fi

cd install_dependencies
echo "installing NEO_OCL driver"
sudo -E ./install_NEO_OCL_driver.sh

# cd ../deployment_tools/inference_engine/lib
# cp -r ubuntu_16.04 ubuntu_18.04

echo "installation complete"
