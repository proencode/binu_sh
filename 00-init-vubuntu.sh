#!/bin/sh

cBlack=$(tput bold)$(tput setaf 0); cRed=$(tput bold)$(tput setaf 1); cGreen=$(tput bold)$(tput setaf 2); cYellow=$(tput bold)$(tput setaf 3); cBlue=$(tput bold)$(tput setaf 4); cMagenta=$(tput bold)$(tput setaf 5); cCyan=$(tput bold)$(tput setaf 6); cWhite=$(tput bold)$(tput setaf 7); cReset=$(tput bold)$(tput sgr0); cUp=$(tput cuu 2)

cat_and_run () {
	echo "${cGreen}----> ${cYellow}$1 ${cCyan}$2${cReset}"; echo "$1" | sh
	echo "${cMagenta}<---- ${cBlue}$1 $2${cReset}"
}
cat_and_read () {
	echo -e "${cGreen}----> ${cYellow}$1 ${cCyan}$2${cGreen}\n----> ${cCyan}press Enter${cReset}:"
	read a ; echo "${cUp}"; echo "$1" | sh
	echo "${cMagenta}<---- ${cBlue}press Enter${cReset}: ${cMagenta}$1 $2${cReset}"
}
cat_and_readY () {
	echo "${cGreen}----> ${cYellow}$1 ${cCyan}$2${cReset}"
	if [ "x${ALL_INSTALL}" = "xy" ]; then
		echo "$1" | sh ; echo "${cMagenta}<---- ${cBlue}$1 $2${cReset}"
	else
		echo "${cGreen}----> ${cRed}press ${cCyan}y${cRed} or Enter${cReset}:"; read a; echo "${cUp}"
		if [ "x$a" = "xy" ]; then
			echo "${cRed}-OK-${cReset}"; echo "$1" | sh
		else
			echo "${cRed}[ ${cYellow}$1 ${cRed}] ${cCyan}<--- 명령을 실행하지 않습니다.${cReset}"
		fi
		echo "${cMagenta}<---- ${cBlue}press Enter${cReset}: ${cMagenta}$1 $2${cReset}"
	fi
}
CMD_NAME=`basename $0` # 명령줄에서 실행 프로그램 이름만 꺼냄
CMD_DIR=${0%/$CMD_NAME} # 실행 이름을 빼고 나머지 디렉토리만 담음
if [ "x$CMD_DIR" == "x" ] || [ "x$CMD_DIR" == "x$CMD_NAME" ]; then
	CMD_DIR="."
fi
MEMO="(1) bash 를 확인하고, 파일공유 프로그램을 설치합니다."
echo "${cMagenta}>>>>>>>>>>${cGreen} $0 ${cMagenta}||| ${cCyan}${MEMO} ${cMagenta}>>>>>>>>>>${cReset}"
logs_folder="${HOME}/zz00-logs" ; if [ ! -d "${logs_folder}" ]; then cat_and_run "mkdir ${logs_folder}" ; fi
log_name="${logs_folder}/zz.$(date +"%y%m%d-%H%M%S")__RUNNING_${CMD_NAME}" ; touch ${log_name}
# ----

ls_sh=$(ls -l /bin/sh | awk -F "->" '{print $2}') #-- '->' 로 쪼갠 2번째 문자열.
if [ "x${ls_sh}" != "x bash" ]; then
	cat <<__EOF__
# ----------
$(ls -al --color /bin/sh) #-- /bin/sh 가 hash 로 되어있지 않습니다.
# ----------

${cGreen}----> ${cYellow}https://faq.hostway.co.kr/Linux_ETC/7267
${cGreen}----> ${cBlue}/bin/sh${cReset} -> ${cRed}bash${cYellow} 로 되어있지 않으므로 수정합니다. 다음 작업에서 '''아니오 (No)''' 를 선택해 주세요.
${cGreen}----> ${cCyan}press Enter${cReset}:
__EOF__
	read a
	cat_and_run "sudo dpkg-reconfigure dash" "#---> '''아니오 (No)''' 를 선택해 주세요."
	cat_and_run "sudo ls -al --color /bin/sh"
	echo "${cGreen}----> ${cCyan}bash 로 수정했습니다. 스크립트를 다시 실행하세요.${cReset}"
	exit 1
fi

cat_and_run "sudo apt -y update" "시스템 업데이트"
cat_and_readY "sudo apt -y upgrade" "시스템 업그레이드"
cat_and_run "sudo apt -y install gcc g++ make perl git build-essential p7zip-full p7zip-rar vim net-tools  openssh-server xrdp gnome-tweaks" "기본으로 설치할 프로그램들"
cat_and_run "dpkg -l | grep kernel" "kernel 버전 확인"

cat_and_readY "sudo /sbin/rcvboxadd quicksetup all" "이작업 시작전에  '''장치 > 게스트 확장 CD 이미지 삽입 > 오류시 재작업'''  을 먼저 끝내야 합니다."
cat_and_run "grep vboxsf /etc/group" "vboxsf 그룹 확인"
cat_and_run "sudo gpasswd -a ${USER} vboxsf ; grep vboxsf /etc/group" "사용자를 vboxsf 그룹에 추가합니다."
cat_and_readY "reboot" "vboxsf 그룹에 ${USER} 사용자가 추가됐다면, 'y' 를 눌러서 다시 시작해야 합니다."

#-- vim

echo "${cGreen}----> ${cCyan}https://itlearningcenter.tistory.com/entry/%E3%80%901804-LTS%E3%80%91VIM-Plug-in-%EC%84%A4%EC%B9%98%ED%95%98%EA%B8%B0${cReset}"
cat_and_run "sudo apt-get install vim" "vim 설치"
cat_and_run "git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim" "VundleVim 설치"
cat_and_run "cp DOTvimrc-vubuntu ~/.vimrc" ".vimrc 설치"
echo "${cGreen}----> ${cYellow}vi +BundleInstall +qall Bundle 설치${cReset}"
vim +BundleInstall +qall

#-- credential.helper

echo "${cYellow}----> ${cCyan}git pull / push 할때 비밀번호 저장 ${cBlue}https://pinedance.github.io/blog/2019/05/29/Git-Credential${gReset}"
echo "${cYellow}----> ${cCyan}gnome 대신 libsecret 사용 ${cBlue}https://www.softwaredeveloper.blog/git-credential-storage-libsecret${cReset}"
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
          a) git config --global credential.helper ‘cache –timeout=300’ (5분동안만 비번없이 진행한다)
          b) git config --global credential.helper cache (cache 만 지정하면 15분동안 비번없이 진행한다)
          c) git config --global credential.helper store (토큰의 유효기간동안 비번없이 진행한다)
__EOF__
cat_and_readY "git config credential.helper store" "이와 같이 저장합니다."

# ----
rm -f ${log_name} ; log_name="${logs_folder}/zz.$(date +"%y%m%d-%H%M%S")..${CMD_NAME}" ; touch ${log_name}
cat_and_run "ls --color ${CMD_DIR}" ; ls --color ${logs_folder}
echo "${cRed}<<<<<<<<<<${cBlue} $0 ${cRed}||| ${cMagenta}${MEMO} ${cRed}<<<<<<<<<<${cReset}"
