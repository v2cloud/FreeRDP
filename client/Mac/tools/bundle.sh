#!/bin/bash

# Make sure to install: ffmpeg-devel, faad, faac, openssl

# git clone https://github.com/v2cloud/FreeRDP.git

git clean -dfx

TOOLS_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
FREERDP_SRC_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/../../.."

cd ${FREERDP_SRC_PATH}/

FREERDP_SRC_PATH=`pwd`

cmake \
-D "CMAKE_OSX_ARCHITECTURES:STRING=x86_64" -D"CMAKE_OSX_DEPLOYMENT_TARGET=10.10" -DWITH_CUPS=ON -DCMAKE_BUILD_TYPE=Release \
-DWITH_FFMPEG=ON \
-DWITH_DSP_FFMPEG=ON \
-DWITH_FAAC=ON \
-DWITH_FAAD2=ON \
-DWITH_GFX_H264=ON  \
-DBUILD_SHARED_LIBS=OFF \
-DMONOLITHIC_BUILD=ON

make -j4

cd client/Mac/cli
mv MacV2ClientRDP.app/Contents/Frameworks/MacFreeRDP.framework/Headers MacV2ClientRDP.app/Contents/Frameworks/MacFreeRDP.framework/Versions/2.0.0/Resources/

install_name_tool -change "${FREERDP_SRC_PATH}/client/Mac/MacFreeRDP.framework/Versions/2.0.0/MacFreeRDP" "@executable_path/../Frameworks/MacFreeRDP.framework/Versions/Current/MacFreeRDP" MacV2ClientRDP.app/Contents/MacOS/MacV2ClientRDP
install_name_tool -id  "@executable_path/MacV2ClientRDP" MacV2ClientRDP.app/Contents/MacOS/MacV2ClientRDP


# Test
# client/Mac/cli/MacV2ClientRDP.app/Contents/MacOS/MacV2ClientRDP /u:Administrator /p:V2demo123 /v:vm10.cloud.devel01.v2cloud.com:63219  /cert-ignore +clipboard  /network:auto /mic /microphone:sys:oss,dev:1,format:1,decoder:ffmpeg  \
#/multimedia:sys:oss,dev:/dev/dsp1,decoder:ffmpeg /sound /gfx-h264:avc444 /gfx:avc444


MACV2CLIENTRDP_PATH=`pwd`
DEPENDENCIES_FILES='dependencies.txt'
LIBS_PATH="${MACV2CLIENTRDP_PATH}/MacV2ClientRDP.app/Contents/Frameworks/MacFreeRDP.framework/Resources/Libraries/"

mkdir -p "${LIBS_PATH}"
python ${TOOLS_PATH}/find_dependencies.py ${MACV2CLIENTRDP_PATH}/MacV2ClientRDP.app/Contents/MacOS/MacV2ClientRDP > "${DEPENDENCIES_FILES}"

while IFS= read line
do
    l="$(echo $line | tr -d '\n')"
    b=$(basename "$l")
    cp "$l" "${LIBS_PATH}"
    chmod +w "${LIBS_PATH}$b"
done <"${DEPENDENCIES_FILES}"

python ${TOOLS_PATH}/fix_libs_linking.py "${LIBS_PATH}"

ln -s  ../Resources ${MACV2CLIENTRDP_PATH}/MacV2ClientRDP.app/Contents/MacOS/Resources
ln -s  ../Frameworks/MacFreeRDP.framework/Resources/Libraries ${MACV2CLIENTRDP_PATH}/MacV2ClientRDP.app/Contents/Resources/Libraries

python ${TOOLS_PATH}/fix_executable_linking.py ${MACV2CLIENTRDP_PATH}/MacV2ClientRDP.app/Contents/MacOS/MacV2ClientRDP
python ${TOOLS_PATH}/fix_executable_linking.py ${MACV2CLIENTRDP_PATH}/MacV2ClientRDP.app/Contents/Frameworks/MacFreeRDP.framework/MacFreeRDP

