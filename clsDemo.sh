#!/bin/bash


usage() {
    echo "Classification demo using public SqueezeNet topology"
    echo "-d name     specify the target device to infer on; CPU, GPU, FPGA or MYRIAD are acceptable. Sample will look for a suitable plugin for device specified"
    echo "-help            print help message"
    exit 1
}

error() {
    local code="${3:-1}"
    if [[ -n "$2" ]];then
        echo "Error on or near line $1: $2; exiting with status ${code}"
    else
        echo "Error on or near line $1; exiting with status ${code}"
    fi
    exit "${code}" 
}
trap 'error ${LINENO}' ERR

target="CPU"

# parse command line options
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h | -help | --help)
    usage
    ;;
    -d)
    target="$2"
    echo target = "${target}"
    shift
    ;;
    -sample-options)
    sampleoptions="$2 $3 $4 $5 $6"
    echo sample-options = "${sampleoptions}"
    shift
    ;;
    *)
    # unknown option
    ;;
esac
shift
done

ROOT_DIR="/opt/intel/computer_vision_sdk/deployment_tools"

model_name="inception-resnet-v2"
target_precision="FP32"
target_image_path="$ROOT_DIR/demo/car.png"

run_again="Then run the script again\n\n"
dashes="\n\n###################################################\n\n"

# Step 1. Download the Caffe model and the prototxt of the model
printf "${dashes}"
printf "\n\nDownloading the Caffe model and the prototxt"

model_dir="${model_name}"
ir_dir="$HOME/openvino_models/ir/${model_name}"
dest_model_proto="${model_name}.prototxt"
dest_model_weights="${model_name}.caffemodel"
cur_path=$PWD

printf "\nInstalling dependencies\n"

if [[ -f /etc/centos-release ]]; then
    DISTRO="centos"
elif [[ -f /etc/lsb-release ]]; then
    DISTRO="ubuntu"
fi


if [[ $DISTRO == "ubuntu" ]]; then
    printf "Run sudo -E apt -y install build-essential python3-pip virtualenv cmake libpng12-dev libcairo2-dev libpango1.0-dev libglib2.0-dev libgtk2.0-dev libswscale-dev libavcodec-dev libavformat-dev libgstreamer1.0-0 gstreamer1.0-plugins-base\n"
    sudo -E apt update
    sudo -E apt -y install build-essential python3-pip virtualenv cmake libpng12-dev libcairo2-dev libpango1.0-dev libglib2.0-dev libgtk2.0-dev libswscale-dev libavcodec-dev libavformat-dev libgstreamer1.0-0 gstreamer1.0-plugins-base
    python_binary=python3
    pip_binary=pip3
fi

if ! command -v $python_binary &>/dev/null; then
    printf "\n\nPython 3.5 (x64) or higher is not installed. It is required to run Model Optimizer, please install it. ${run_again}"
    exit 1
fi

sudo -E $pip_binary install pyyaml requests

printf "Run $ROOT_DIR/model_downloader/downloader.py --name \"${model_name}\" --output_dir \"$HOME/openvino_models\"\n\n"
$python_binary "$ROOT_DIR/model_downloader/downloader.py" --name "${model_name}" --output_dir "$HOME/openvino_models"

# Step 2. Configure Model Optimizer
printf "${dashes}"
printf "Configure Model Optimizer\n\n"

if [[ -z "${INTEL_CVSDK_DIR}" ]]; then
    printf "\n\nINTEL_CVSDK_DIR environment variable is not set. Trying to run ./setvars.sh to set it. \n"
    
    if [ -e "$ROOT_DIR/inference_engine/bin/setvars.sh" ]; then # for Intel Deep Learning Deployment Toolkit package
        setvars_path="$ROOT_DIR/inference_engine/bin/setvars.sh"
    elif [ -e "$ROOT_DIR/../bin/setupvars.sh" ]; then # for Intel CV SDK package
        setvars_path="$ROOT_DIR/../bin/setupvars.sh"
    elif [ -e "$ROOT_DIR/../setupvars.sh" ]; then # for Intel GO SDK package
        setvars_path="$ROOT_DIR/../setupvars.sh"
    else
        printf "Error: setvars.sh is not found\n"
    fi 
    if ! source $setvars_path ; then
        printf "Unable to run ./setvars.sh. Please check its presence. ${run_again}"
        exit 1
    fi
fi



printf "${dashes}"
printf "Install Model Optimizer dependencies\n\n"
cd "${INTEL_CVSDK_DIR}/deployment_tools/model_optimizer/install_prerequisites"
source "${INTEL_CVSDK_DIR}/deployment_tools/model_optimizer/install_prerequisites/install_prerequisites.sh" caffe
cd $cur_path

# Step 3. Convert a model with Model Optimizer
printf "${dashes}"
printf "Convert a model with Model Optimizer\n\n"

mo_path="${INTEL_CVSDK_DIR}/deployment_tools/model_optimizer/mo.py"

if [ ! -e $ir_dir ]; then
    export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp
    printf "Run $python_binary $mo_path --input_model $HOME//openvino_models/classification/inception-resnet/v2/caffe/inception-resnet-v2.caffemodel --output_dir $ir_dir --data_type $target_precision\n\n"
    $python_binary $mo_path --input_model "$HOME//openvino_models/classification/inception-resnet/v2/caffe/inception-resnet-v2.caffemodel" --output_dir $ir_dir --data_type $target_precision
else
    printf "\n\nTarget folder ${ir_dir} already exists. Skipping IR generation."
    printf "If you want to convert a model again, remove the entire ${$ir_dir} folder. ${run_again}"
    return
fi

# Step 4. Build samples
printf "${dashes}"
printf "Build Inference Engine samples\n\n"

samples_path="${INTEL_CVSDK_DIR}/deployment_tools/inference_engine/samples"

if ! command -v cmake &>/dev/null; then
    printf "\n\nCMAKE is not installed. It is required to build Inference Engine samples. Please install it. ${run_again}"
    exit 1
fi

build_dir="$HOME/inference_engine_samples"
if [ ! -e "$build_dir/intel64/Release/classification_sample" ]; then
    mkdir -p $build_dir
    cd $build_dir
    cmake -DCMAKE_BUILD_TYPE=Release $samples_path
    make -j8
else
    printf "\n\nTarget folder ${build_dir} already exists. Skipping samples building."
    printf "If you want to rebuild samples, remove the entire ${build_dir} folder. ${run_again}"
fi

# Step 5. Run samples
printf "${dashes}"
printf "Run Inference Engine classification sample\n\n"

binaries_dir="${build_dir}/intel64/Release"
cd $binaries_dir

printf "Run ./classification_sample -d $target -i $target_image_path -m ${ir_dir}/inception-resnet.xml ${sampleoptions}\n\n"
# cp -f $ROOT_DIR/demo/squeezenet1.1.labels ${ir_dir}/

./classification_sample -d $target -i $target_image_path -m "${ir_dir}/inception-resnet-v2.xml" ${sampleoptions}

printf "${dashes}"
printf "Demo completed successfully.\n\n"