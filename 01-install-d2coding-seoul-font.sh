#!/bin/sh

source ${HOME}/bin/color_base #-- 221027목-1257 CMD_DIR CMD_NAME cmdRun cmdCont cmdYenter echoSeq 
MEMO="(01) 한글 폰트파일 설치"
cat <<__EOF__
${cMagenta}>>>>>>>>>>${cGreen} $0 ${cMagenta}||| ${cCyan}${MEMO} ${cMagenta}>>>>>>>>>>${cReset}
__EOF__
zz00logs_folder="${HOME}/zz00logs" ; if [ ! -d "${zz00logs_folder}" ]; then cmdRun "mkdir ${zz00logs_folder}" "로그 폴더" ; fi
zz00log_name="${zz00logs_folder}/zz.$(date +"%y%m%d%a-%H%M%S")__RUNNING_${CMD_NAME}" ; touch ${zz00log_name}
# ----


if [ "x$1" = "x" ]; then
	echo "${cRed}!!!! ${cMagenta}----> ${cBlue}(1) 프로그램 이름 다음에 ${cCyan}저장하기 위해 ${cYellow}/media/sf_Downloads/ 등 ${cBlue}폴더 이름을 지정해야 합니다.${cReset}"
	echo "----> ${cYellow}${0} [임시파일을 저장할 폴더이름]${cReset}"
	exit
fi
if [ ! -d "$1" ]; then
	echo "${cRed}!!!! ${cMagenta}----> ${cBlue}(2) 저장하기 위한 ${cCyan}( ${cYellow}$1 ${cCyan})${cBlue} 폴더가 없습니다.${cReset}"
	echo "----> ${cYellow}${0} [임시파일을 저장할 폴더이름]${cReset}"
	exit
fi


echo "${cYellow}# ---> ${cGreen}(3) D2Coding 폰트 설치${cReset}"

TEMPfontDIR="$1/temp_fonts"
WGET="wget --no-check-certificate --content-disposition"

cmdRun "rm -rf ${TEMPfontDIR} ; mkdir ${TEMPfontDIR}" "(4) 임시로 쓰는 폴더를 새로 만듭니다."

FONT_HOST="https://github.com/naver/d2codingfont/releases/download/VER1.3.2"
FONT_NAME="D2Coding-Ver1.3.2-20180524.zip"
FONT_DIR="/usr/share/fonts"
LOCAL_DIR="${FONT_DIR}/D2Coding"

cmdRun "cd ${TEMPfontDIR} ; ${WGET} ${FONT_HOST}/${FONT_NAME}" "(5) 폰트 내려받기"
cmdRun "sudo rm -rf ${LOCAL_DIR}*" "(6) 기존 폴더 삭제"
cmdRun "cd ${TEMPfontDIR} ; 7za x ${FONT_NAME}" "(7) 폰트 압축해제"
cmdRun "cd ${TEMPfontDIR} ; sudo chown -R root.root D2Coding ; sudo mv D2Coding ${FONT_DIR}/ ; sudo chmod 755 -R ${LOCAL_DIR} ; sudo chmod 644 ${LOCAL_DIR}/*" "(8) 폰트 설치"
cmdRun "cd ${LOCAL_DIR} ; sudo mv D2Coding-Ver1.3.2-20180524.ttc D2Coding.ttc ; sudo mv D2Coding-Ver1.3.2-20180524.ttf D2Coding.ttf ; sudo mv D2CodingBold-Ver1.3.2-20180524.ttf D2CodingBold.ttf" "(9) 폰트 파일이름을 수정합니다."


echo "${cYellow}# ---> ${cGreen}(10) seoul 폰트 설치${cReset}"

cmdRun "sudo rm -rf ${TEMPfontDIR} ; mkdir ${TEMPfontDIR}" "(11) 임시폴더 다시만들고,"

FONT_HOST="https://www.seoul.go.kr/upload/seoul/font"
FONT_NAME="seoul_font.zip" #-- 파일을 한글코드로 된 폴더에 담아서 압축했기 때문에, 풀면 fedora35 에서 깨진 글자로 나온다.
LOCAL_DIR="${FONT_DIR}/seoul"

cmdRun "cd ${TEMPfontDIR} ; ${WGET} ${FONT_HOST}/${FONT_NAME}" "(12) 폰트 내려받기"
cmdRun "sudo rm -rf ${LOCAL_DIR} ; sudo mkdir ${LOCAL_DIR}" "(13) 폴더 만들기"
cmdRun "cd ${TEMPfontDIR} ; ls -l ; 7za x ${FONT_NAME}" "(14) 폰트 압축해제"
cmdRun "cd ${TEMPfontDIR} ; sudo mv */Seoul*.ttf ${LOCAL_DIR}/ ; sudo chmod 644 ${LOCAL_DIR}/*" "(15) 폰트 설치"


echo "${cYellow}# ---> ${cGreen}(16) 폰트 설치 확인${cReset}"

cmdRun "ls -ltr --color ${FONT_DIR}" "(17) 시간역순 font 디렉토리"
cmdRun "ls --color ${FONT_DIR}/D2Coding*" "(18) d2coding 설치 확인"
cmdRun "ls --color ${FONT_DIR}/seoul*" "(19) seoul 설치 확인"

cmdRun "sudo rm -rf ${TEMPfontDIR}" "(20) 임시폴더 삭제"


# ----
rm -f ${zz00log_name} ; zz00log_name="${zz00logs_folder}/zz.$(date +"%y%m%d%a-%H%M%S")..${CMD_NAME}" ; touch ${zz00log_name}
ls --color ${zz00logs_folder}
cat <<__EOF__
${cRed}<<<<<<<<<<${cBlue} $0 ${cRed}||| ${cMagenta}${MEMO} ${cRed}<<<<<<<<<<${cReset}
__EOF__
