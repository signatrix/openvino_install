#!/bin/bash

echo "extracting toolkit"

sudo apt -y install expect sshpass

sshpass -p "red" scp red@192.168.1.49:/media/backup1/install_files/l_openvino_toolkit_p_2018.3.343.tgz .

tar -zxf l_openvino_toolkit_p_2018.3.343.tgz
cd l_openvino_toolkit_p_2018.3.343
cp ../expecter.sh ./expecter.sh

cp ../patch/install_cv_sdk_dependencies.sh install_cv_sdk_dependencies.sh

echo "installing dependencies"
./install_cv_sdk_dependencies.sh

echo "installing toolkit"
./expecter.sh

echo "patching version"
cp ../patch/install_NEO_OCL_driver.sh /opt/intel/computer_vision_sdk/install_dependencies/install_NEO_OCL_driver.sh
cp ../patch/InferenceEngineConfig.cmake /opt/intel/computer_vision_sdk/deployment_tools/inference_engine/share/InferenceEngineConfig.cmake
cp ../patch/CMakeLists.txt /opt/intel/computer_vision_sdk/deployment_tools/inference_engine/samples/CMakeLists.txt

echo "setting up environment variables. Adding to zshrc"
cd /opt/intel/computer_vision_sdk
source bin/setupvars.sh
echo 'source /opt/intel/computer_vision_sdk/bin/setupvars.sh' >> ~/.zshrc

cd install_dependencies
./install_NEO_OCL_driver.sh

cd ../deployment_tools/inference_engine/lib
cp -r ubuntu_16.04 ubuntu_18.04

echo "installation complete"