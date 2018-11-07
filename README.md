# openvino installation:

You can install openvino natively in 18.04 or via docker container in Ubuntu16.04.

In this folder you need to include a pip wheel for the tensorflow installation and the openvino toolkit tgz file. Change names as needed in the Dockerfile.

The docker image will create a Ubuntu16.04 image able to run openVino code and running the tensorflow installation you provide with the wheel.

You can find some good pip wheels to include on the server at /media/backup1/wheels. Include a python3.5 tf1.11 variant.



Start using 

docker run --device=/dev/dri:/dev/dri 
