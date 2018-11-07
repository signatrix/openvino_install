# openvino-install

In this folder you can include a pip wheel for the tensorflow installation and the openvino toolkit tgz file. Change names as needed in the Dockerfile.

The docker image will create a Ubuntu16.04 image able to run openVino code and running the tensorflow installation you provide with the wheel.

You can find some good pip wheels to include on the server at /media/backup1/wheels. Include a python3.5 tf1.11 variant. or let it download it's own version(might not be optimized)

The native version downloads the toollkit from the 192.168.1.49. Might need to change path/ip or something if it is not up to date.



#Usage:
For docker
docker run --device=/dev/dri:/dev/dri 

For native:
sudo ./install.sh