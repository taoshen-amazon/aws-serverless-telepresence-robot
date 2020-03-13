#!/bin/bash

# Copyright 2020 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

sudo apt-get update
sudo apt-get -y upgrade

sudo apt-get -y install curl
sudo apt-get -y install python3
sudo apt-get -y install g++ gcc cmake make
sudo apt-get -y install libssl-dev libcurl4-openssl-dev liblog4cplus-1.1-9 liblog4cplus-dev
sudo apt-get -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt-get -y install gstreamer1.0-plugins-base-apps gstreamer1.0-plugins-bad
sudo apt-get -y install gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-tools
sudo apt-get -y install gstreamer1.0-omx
sudo apt-get -y install python3-explorerhat
pip3 install AWSIoTPythonSDK

if [ ! -d /home/pi/Projects ]
then
  mkdir /home/pi/Projects
  cd /home/pi/Projects
else
  cd /home/pi/Projects
fi

if [ ! -d /home/pi/Projects/amazon-kinesis-video-streams-webrtc-sdk-c ]
then
  git clone --recursive https://github.com/awslabs/amazon-kinesis-video-streams-webrtc-sdk-c.git
  cd /home/pi/Projects/amazon-kinesis-video-streams-webrtc-sdk-c
else
  cd /home/pi/Projects/amazon-kinesis-video-streams-webrtc-sdk-c
  git pull
fi

git checkout aa9628d189719e6fe2f709347c5a62d93a3ff98d
cd /home/pi/Projects/amazon-kinesis-video-streams-webrtc-sdk-c/samples
rm /home/pi/Projects/amazon-kinesis-video-streams-webrtc-sdk-c/samples/Common.c
curl --silent 'https://raw.githubusercontent.com/aws-samples/aws-serverless-telepresence-robot/master/scripts/modified-common.c' --output Common.c

cd /home/pi/Projects/amazon-kinesis-video-streams-webrtc-sdk-c
mkdir build
cd build
cmake ..
make

if [ ! -d /home/pi/Projects/robot ]
then
  mkdir /home/pi/Projects/robot
  cd /home/pi/Projects/robot
else
  cd /home/pi/Projects/robot
fi

cp /home/pi/Projects/amazon-kinesis-video-streams-webrtc-sdk-c/build/kvsWebrtcClientMasterGstSample /home/pi/Projects/robot/
curl --silent 'https://www.amazontrust.com/repository/SFSRootCAG2.pem' --output cacert.pem
curl --silent 'https://raw.githubusercontent.com/aws-samples/aws-serverless-telepresence-robot/master/scripts/main.py' --output main.py
touch certificate.pem
touch private.pem.key

cat > config.json <<EOF
{
  "IOT_THINGNAME": "",
  "IOT_CORE_ENDPOINT": "",
  "IOT_GET_CREDENTIAL_ENDPOINT": "",
  "ROLE_ALIAS": "robot-camera-streaming-role-alias",
  "AWS_DEFAULT_REGION": ""
}
EOF