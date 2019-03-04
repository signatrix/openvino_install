# Installing Openvino on Ubuntu 18.04

As of November 2018 Intel's Openvino Toolkit does not officially support ubuntu 18.04. Some simple hacks make it possible to install it however.

Please include the openvino toolkit tgz file in this folder. Depending on which version you downloaded you might need to change a few path names in the Dockerfile/install.sh script.

Install.sh will copy the few files from the patch folder to replace the ones not compatible with ubuntu 18.04

---

# Creating an Openvino docker image

I was not able to find any official docker images so here is one for your convenience.

The Dockerfile will create an Ubuntu16.04 image able to run openVino code.

---

# Usage:

For docker
* docker build . -t name:tag
* docker run --device=/dev/dri:/dev/dri -it name:tag 

For native:
* sudo ./install.sh

---

# Just converting:

If you just want to convert a model to intel intermediate representation:
* Modify docker-compose file to mount the needed directories
* Call ./convert_model.sh with the parameters the model_optimizer needs.