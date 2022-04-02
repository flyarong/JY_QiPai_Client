#!/bin/sh

LOGIN_USER_NAME=mac
UNITY3D_PROJECT_PATH="/Users/mac/JyQipai_client/1_code"
UNITY3D_DATA_PATH="/Users/mac/JyQipai_client/1_code/Assets/StreamingAssets"
UNITY3D_BUILD_METHOD="Packager.Export"
UNITY3D_EXE="/Applications/Unity/Unity.app/Contents/MacOS/Unity"
UNITY3D_OUTPUT_PATH="/Users/${LOGIN_USER_NAME}/Desktop/IOS/"

IPA_PATH="/Users/${LOGIN_USER_NAME}/Desktop/IOS/IPA"

rm -rf ${UNITY3D_OUTPUT_PATH}

#cd ./JyQipai_client
#git reset --hard
#git pull
#cd ..

${UNITY3D_EXE} -quit -batchmode -projectPath ${UNITY3D_PROJECT_PATH} -executeMethod ${UNITY3D_BUILD_METHOD} -exportPath ${UNITY3D_OUTPUT_PATH} -platformType "IOS" -debugMode "false" -logFile

cd ${UNITY3D_OUTPUT_PATH}
#xcodebuild clean -scheme Unity-iPhone -configuration Release archive -archivePath ${UNITY3D_OUTPUT_PATH}/build/Release-iphoneos/Unity-iPhone.xcarchive

#xcodebuild -exportArchive -archivePath ${UNITY3D_OUTPUT_PATH}/build/Release-iphoneos/Unity-iPhone.xcarchive -exportPath ${IPA_PATH} -exportOptionsPlist "Info.plist"

mkdir ${IPA_PATH}
#cd ${UNITY3D_OUTPUT_PATH}/Data/Raw
cd ${UNITY3D_DATA_PATH}
zip -q -r ${IPA_PATH}/Unity-iPhone.zip *

sftp -P24 jingyu@120.79.190.11<<EOF
-put ${IPA_PATH}/Unity-iPhone.zip
quit
EOF

