#!/bin/bash

# Make sure to install: ffmpeg-devel, faad, faac, openssl

# git clone https://github.com/v2cloud/FreeRDP.git

TOOLS_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
FREERDP_SRC_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/../../.."

cd ${FREERDP_SRC_PATH}/

FREERDP_SRC_PATH=`pwd`

cmake -D "CMAKE_OSX_ARCHITECTURES:STRING=x86_64" -DWITH_CUPS=ON  -DCMAKE_BUILD_TYPE=Release -DWITH_FFMPEG=ON -DWITH_DSP_FFMPEG=ON -DWITH_FAAC=ON -DWITH_FAAD2=ON -DWITH_GFX_H264=ON -DBUILD_SHARED_LIBS=OFF -DMONOLITHIC_BUILD=ON

make -j4

cd client/Mac/cli
mv MacV2ClientRDP.app/Contents/Frameworks/MacFreeRDP.framework/Headers MacV2ClientRDP.app/Contents/Frameworks/MacFreeRDP.framework/Versions/2.0.0/Resources/
ln -s  MacV2ClientRDP.app/Contents/Frameworks/MacFreeRDP.framework/Versions/2.0.0/Resources/Headers MacV2ClientRDP.app/Contents/Frameworks/MacFreeRDP.framework/Headers

install_name_tool -change "${FREERDP_SRC_PATH}/client/Mac/MacFreeRDP.framework/Versions/2.0.0/MacFreeRDP" "@executable_path/../Frameworks/MacFreeRDP.framework/Versions/Current/MacFreeRDP" MacV2ClientRDP.app/Contents/MacOS/MacV2ClientRDP
install_name_tool -id  "@executable_path/MacV2ClientRDP" MacV2ClientRDP.app/Contents/MacOS/MacV2ClientRDP


# Test
# MacV2ClientRDP.app/Contents/MacOS/MacV2ClientRDP /u:<username> /p:<pass> /v:<ip>:<port> \
# /cert-ignore +clipboard /mic /sound /gfx:avc444 /network:auto /microphone:sys:oss,dev:1,format:1 \
# /multimedia:sys:oss,dev:/dev/dsp1,decoder:ffmpeg


MACV2CLIENTRDP_PATH=`pwd`

python find_dependencies.py ${MACV2CLIENTRDP_PATH}/MacV2ClientRDP.app/Contents/MacOS/MacV2ClientRDP
python copy_and_fix_libs_linking.py ${MACV2CLIENTRDP_PATH}/MacV2ClientRDP.app/Contents/Frameworks/MacFreeRDP.framework/Resources

ln -s  ${MACV2CLIENTRDP_PATH}/MacV2ClientRDP.app/Contents/Frameworks/MacFreeRDP.framework/Resources ${MACV2CLIENTRDP_PATH}/MacV2ClientRDP.app/Contents/MacOS/Resources
ln -s  ${MACV2CLIENTRDP_PATH}/MacV2ClientRDP.app/Contents/Frameworks/MacFreeRDP.framework/Resources/Libraries ${MACV2CLIENTRDP_PATH}/MacV2ClientRDP.app/Contents/MacOS/Resources/Libraries

python fix_executable_linking.py ${MACV2CLIENTRDP_PATH}/MacV2ClientRDP.app/Contents/MacOS/MacV2ClientRDP
python fix_executable_linking.py ${MACV2CLIENTRDP_PATH}/MacV2ClientRDP.app/Contents/Frameworks/MacFreeRDP.framework/MacFreeRDP

