#!/bin/sh 

cBlack=$(tput bold)$(tput setaf 0); cRed=$(tput bold)$(tput setaf 1); cGreen=$(tput bold)$(tput setaf 2); cYellow=$(tput bold)$(tput setaf 3); cBlue=$(tput bold)$(tput setaf 4); cMagenta=$(tput bold)$(tput setaf 5); cCyan=$(tput bold)$(tput setaf 6); cWhite=$(tput bold)$(tput setaf 7); cReset=$(tput bold)$(tput sgr0); cUp=$(tput cuu 2)

cat_and_run () {
	echo "${cYellow}----> ${cGreen}$1 ${cCyan}$2${cReset}"; echo "$1" | sh
	echo "${cYellow}<${cMagenta}---- ${cBlue}$1 $2${cReset}"
}
cat_and_read () {
	echo -e "${cYellow}----> ${cGreen}$1 ${cCyan}$2${cYellow}\n - -> ${cRed}press Enter${cCyan}:${cReset}"
	read a ; echo "${cUp}"; echo "$1" | sh
	echo "${cYellow}<${cMagenta} - - ${cBlue}press Enter${cRed}: ${cMagenta}$1 $2${cReset}"
}
cat_and_readY () {
	echo "${cYellow}----> ${cGreen}$1 ${cCyan}$2${cReset}"
	if [ "x${ALL_INSTALL}" = "xy" ]; then
		echo "$1" | sh ; echo "${cYellow}<${cMagenta}---- ${cBlue}$1${cReset}"
	else
		echo "${cYellow} - -> ${cRed}press ${cCyan}y${cRed} or Enter${cCyan}:${cReset}"; read a; echo "${cUp}"
		if [ "x$a" = "xy" ]; then
			echo "${cRed}-OK-${cReset}"; echo "$1" | sh
		else
			echo "${cRed}$1 ${cYellow}--- 를 실행하지 않습니다.${cReset}"
		fi
		echo "${cYellow}<${cMagenta} - - ${cBlue}press Enter${cRed}: ${cMagenta}$1 $2${cReset}"
	fi
}

ls_sh=$(ls -l /bin/sh | awk -F "->" '{print $2}') #-- '->' 로 쪼갠 2번째 문자열.
if [ "x${ls_sh}" != "x bash" ]; then
	cat <<__EOF__
# ----------
$(ls -al --color /bin/sh)
# ----------

----> https://faq.hostway.co.kr/Linux_ETC/7267
----> ${cBlue}/bin/sh${cReset} -> ${cRed}bash${cReset} 로 되어있지 않으므로 수정합니다. 다음 작업에서 '''아니오 (No)''' 를 선택해 주세요."
__EOF__
	read a
	cat_and_run "sudo dpkg-reconfigure dash" "#---> '''아니오 (No)''' 를 선택해 주세요."
	cat_and_run "sudo ls -al --color /bin/sh"
	exit 1 # echo "----> ${cRed}press Enter${cCyan}:${cReset}" ; read a
fi

CMD_NAME=`basename $0` # 명령줄에서 실행 프로그램 이름만 꺼냄
CMD_DIR=${0%/$CMD_NAME} # 실행 이름을 빼고 나머지 디렉토리만 담음
if [ "x$CMD_DIR" == "x" ] || [ "x$CMD_DIR" == "x$CMD_NAME" ]; then
	CMD_DIR="."
fi

# ----------
MEMO="Docker+compose in ubuntu 20.04 https://cholee714.tistory.com/30"
echo "${cYellow}>>>>>>>>>>${cGreen} $0 ||| ${cCyan}${MEMO} ${cYellow}>>>>>>>>>>${cReset}"

if [ "x$1" = "x" ]; then
	echo "${cRed}!!!! ${cMagenta}----> ${cBlue} 프로그램 이름 다음에 ${cCyan}(임시로 쓸 폴더)${cBlue}를 지정해야 합니다.${cReset}"
	echo "----> ${cYellow}${0} [임시로 쓸 폴더이름]${cReset}"
	exit
fi
if [ ! -d "$1" ]; then
	echo "${cRed}!!!! ${cMagenta}----> ${cBlue} 임시로 쓸 ${cCyan}($1)${cBlue} 폴더가 없습니다.${cReset}"
	echo "----> ${cYellow}${0} [임시로 쓸 폴더이름]${cReset}"
	exit
fi
FONT_DIR="/usr/share/fonts"
WGET="wget --no-check-certificate --content-disposition"
TEMPfontDIR="$1/temp_fonts"

#-- 프로그램 설치

cat_and_run "sudo apt update -y"
#-xx && sudo apt upgrade -y #-- 양이 많아서 제외한다.
cat_and_run "sudo apt install -y gcc g++ make perl git build-essential p7zip-full p7zip-rar vim" "기본으로 설치할 프로그램들"
cat_and_run "dpkg -l | grep kernel" "kernel 버전 확인"

cat_and_readY "sudo /sbin/rcvboxadd quicksetup all" "장치 > 게스트 확장 CD 이미지 삽입 > 오류시 재작업"
cat_and_run "grep vboxsf /etc/group" "vboxsf 그룹 확인"
cat_and_run "sudo gpasswd -a ${USER} vboxsf ; grep vboxsf /etc/group" "사용자를 vboxsf 그룹에 추가합니다."
cat_and_readY "reboot" "vboxsf 그룹에 ${USER} 사용자가 추가됐다면, 'y' 를 눌러서 다시 시작해야 합니다."

# --- 폰트 설치

cat_and_run "rm -rf ${TEMPfontDIR} ; mkdir ${TEMPfontDIR}" "임시로 쓸 폴더를 새로 만듭니다."

FONT_HOST="https://github.com/naver/d2codingfont/releases/download/VER1.3.2"
FONT_NAME="D2Coding-Ver1.3.2-20180524.zip"
LOCAL_DIR="${FONT_DIR}/D2Coding"

cat_and_run "cd ${TEMPfontDIR} ; ${WGET} ${FONT_HOST}/${FONT_NAME}" "폰트 내려받기"
cat_and_run "sudo rm -rf ${LOCAL_DIR}*" "기존 폴더 삭제"
cat_and_run "cd ${TEMPfontDIR} ; 7za x ${FONT_NAME}" "폰트 압축해제"
cat_and_run "cd ${TEMPfontDIR} ; sudo mv D2Coding ${FONT_DIR}/ ; sudo chmod 755 -R ${LOCAL_DIR} ; sudo chmod 644 ${LOCAL_DIR}/*" "폰트 설치"
cat_and_run "cd ${LOCAL_DIR} ; sudo mv D2Coding-Ver1.3.2-20180524.ttc D2Coding.ttc ; sudo mv D2Coding-Ver1.3.2-20180524.ttf D2Coding.ttf ; sudo mv D2CodingBold-Ver1.3.2-20180524.ttf D2CodingBold.ttf" "폰트 파일이름을 수정합니다."

# --- 폰트 설치

cat_and_run "sudo rm -rf ${TEMPfontDIR} ; mkdir ${TEMPfontDIR}" "임시폴더 다시만들고,"

FONT_HOST="https://www.seoul.go.kr/upload/seoul/font"
FONT_NAME="seoul_font.zip" #-- 파일을 한글코드로 된 폴더에 담아서 압축했기 때문에, 풀면 fedora35 에서 깨진 글자로 나온다.
LOCAL_DIR="${FONT_DIR}/seoul"

cat_and_run "cd ${TEMPfontDIR} ; ${WGET} ${FONT_HOST}/${FONT_NAME}" "폰트 내려받기"
cat_and_run "sudo rm -rf ${LOCAL_DIR} ; sudo mkdir ${LOCAL_DIR}" "폴더 만들기"
cat_and_run "cd ${TEMPfontDIR} ; ls -l ; 7za x ${FONT_NAME}" "폰트 압축해제"
cat_and_run "cd ${TEMPfontDIR} ; sudo mv */Seoul*.ttf ${LOCAL_DIR}/ ; sudo chmod 644 ${LOCAL_DIR}/*" "폰트 설치"

# --- 확인

cat_and_run "ls --color ${FONT_DIR}/D2Coding*" "d2coding 설치 확인"
cat_and_run "ls --color ${FONT_DIR}/seoul*" "seoul 설치 확인"
cat_and_run "sudo rm -rf ${TEMPfontDIR}" "임시폴더 삭제"

# --- vim 설치

echo "${cYellow}----> ${cCyan}https://itlearningcenter.tistory.com/entry/%E3%80%901804-LTS%E3%80%91VIM-Plug-in-%EC%84%A4%EC%B9%98%ED%95%98%EA%B8%B0${cReset}"
cat_and_run "sudo apt-get install vim" "vim 설치"
cat_and_run "git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim" "VundleVim 설치"
cat_and_run "cp DOTvimrc-vubuntu ~/.vimrc" ".vimrc 설치"
echo "----> vi +BundleInstall +qall Bundle 설치"
vim +BundleInstall +qall

echo "${cYellow}----> ${cCyan}git pull push 할때 비밀번호 저장 ${cBlue}https://pinedance.github.io/blog/2019/05/29/Git-Credential${gReset}"
echo "${cYellow}----> ${cCyan}gnome 대신 libsecret 사용${cBlue}https://www.softwaredeveloper.blog/git-credential-storage-libsecret${cReset}"
cat_and_run "sudo apt-get install -y libsecret-1-0 libsecret-1-dev" "라이브러리 설치"
cat_and_run "cd /usr/share/doc/git/contrib/credential/libsecret ; sudo make" "컴파일"
cat_and_run "git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret" "설치"
cat <<__EOF__
#-- github 비번관리
1. https://github.com 로그인 후,
   1) 우상단 프로필 사진 클릭 > 설정 Setting 클릭
   2) 좌 사이드바에서 개발자 설정 Developer setting 클릭
   3) 개인 액세스 토큰 Personal access token 클릭
   4) 새 토큰 생성 Generate new token 클릭 > 권한에서 저장소 액세스 repo 선택
   5) 토큰 생성 Generate token
   6) 토큰을 복사한다.
2. 저장소 repository 복사.
   1) git clone https://proencode@github.com/proencode/run_sh.git
      (1) 이때 비밀번호를 물어오면 토큰을 입력한다.
      (2) 위 비번을 저장하기 위해 다음 명령을 실행한다.
          a) git config –global credential-helper ‘cache –timeout=300’ (5분동안만 비번없이 진행한다)
          b) git config –global credential-helper cache (cache 만 지정하면 15분동안 비번없이 진행한다)
          c) git config –global credential-helper store (토큰의 유효기간동안 비번없이 진행한다)
__EOF__
cat_and_readY "git config credential.helper store" "이와 같이 저장합니다."

cat_and_run "ls --color ${CMD_DIR}"
echo "${cYellow}>>>>>>>>>>${cGreen} $0 ||| ${cCyan}${MEMO} ${cYellow}>>>>>>>>>>${cReset}"
