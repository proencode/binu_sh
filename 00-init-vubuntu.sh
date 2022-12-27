#!/bin/sh

source ${HOME}/bin/color_base #-- 221027목-1257 CMD_DIR CMD_NAME cmdRun cmdCont cmdYenter echoSeq 
MEMO="(00) bash 를 쓰도록 하고, 파일공유 프로그램을 설치합니다."
cat <<__EOF__
${cMagenta}>>>>>>>>>>${cGreen} $0 ${cMagenta}||| ${cCyan}${MEMO} ${cMagenta}>>>>>>>>>>${cReset}
__EOF__
zz00logs_folder="${HOME}/zz00logs" ; if [ ! -d "${zz00logs_folder}" ]; then cmdRun "mkdir ${zz00logs_folder}" "로그 폴더" ; fi
zz00log_name="${zz00logs_folder}/zz.$(date +"%y%m%d%a-%H%M%S")__RUNNING_${CMD_NAME}" ; touch ${zz00log_name}
# ----


ls_sh=$(ls -l /bin/sh | awk -F "->" '{print $2}') #-- '->' 로 쪼갠 2번째 문자열.
if [ "x${ls_sh}" != "x bash" ]; then
	cat <<__EOF__
# ----------
$(ls -al --color /bin/sh) #-- /bin/sh 가 hash 로 되어있지 않습니다.
# ----------

${cGreen}----> (1) ${cBlue}/bin/sh${cReset} -> ${cRed}bash${cYellow} 로 되어있지 않으므로 수정합니다. 다음 작업에서 '''아니오 (No)''' 를 선택해 주세요.
${cGreen}----> ${cYellow}https://faq.hostway.co.kr/Linux_ETC/7267
${cGreen}----> ${cCyan}press Enter${cReset}:
__EOF__
	read a
	#-- https://superuser.com/questions/715722/how-to-do-dpkg-reconfigure-dash-as-bash-automatically
	echo "----> (2) echo \"dash dash/sh boolean false\" | sudo debconf-set-selections ; DEBIAN_FRONTEND=noninteractive ; sudo dpkg-reconfigure dash"
	echo "dash dash/sh boolean false" | sudo debconf-set-selections
	DEBIAN_FRONTEND=noninteractive
	sudo dpkg-reconfigure dash
	#xxx--- cmdRun "sudo dpkg-reconfigure dash" "#---> '''아니오 (No)''' 를 선택해 주세요."
	cmdRun "sudo ls -al --color /bin/sh"
	echo "${cGreen}----> (3) ${cCyan}bash 로 수정했습니다. 스크립트를 다시 실행하세요.${cReset}"
	exit 1
fi
#----
#----
#----
cmdYenter "sudo apt -y update ; sudo apt-get -y update" "시스템 업데이트"
cmdYenter "sudo apt -y upgrade ; sudo apt-get -y upgrade" "시스템 업그레이드"
cmdRun "sudo apt -y install gcc g++ make perl git build-essential p7zip-full p7zip-rar vim net-tools  openssh-server xrdp gnome-tweaks" "(4) 기본으로 설치할 프로그램들"
cmdRun "dpkg -l | grep kernel" "(5) kernel 버전 확인"
#----
#----
#----
cmdYenter "sudo /sbin/rcvboxadd quicksetup all" "(6) 이작업 시작전에  '''장치 > 게스트 확장 CD 이미지 삽입 > sudo ./VBoxLinuxAdditions.run > 오류시 재작업'''  을 먼저 끝내야 합니다."
cmdYenter "grep vboxsf /etc/group" "(7) vboxsf 그룹 확인"
cmdYenter "sudo gpasswd -a ${USER} vboxsf ; grep vboxsf /etc/group" "(8) 사용자를 vboxsf 그룹에 추가합니다."
# cmdYenter "reboot" "vboxsf 그룹에 ${USER} 사용자가 추가됐다면, 'y' 를 눌러서 다시 시작해야 합니다."
#----
#----
#----
#-- vim
#----
#----
#----
echo "${cGreen}----> ${cCyan}https://itlearningcenter.tistory.com/entry/%E3%80%901804-LTS%E3%80%91VIM-Plug-in-%EC%84%A4%EC%B9%98%ED%95%98%EA%B8%B0${cReset}"
cmdRun "sudo apt-get install vim" "(9) vim 설치"
cmdRun "git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim" "(10) VundleVim 설치"
cmdRun "cp DOTvimrc-vubuntu ~/.vimrc" "(11) .vimrc 설치"
echo "${cGreen}----> (12) ${cYellow}vi +BundleInstall +qall Bundle 설치${cReset}"
vim +BundleInstall +qall
#----
#----
#----
#-- credential.helper
#----
#----
#----
echo "${cYellow}----> ${cCyan}git pull / push 할때 비밀번호 저장 ${cBlue}https://pinedance.github.io/blog/2019/05/29/Git-Credential${gReset}"
echo "${cYellow}----> ${cCyan}gnome 대신 libsecret 사용 ${cBlue}https://www.softwaredeveloper.blog/git-credential-storage-libsecret${cReset}"
cmdRun "sudo apt-get install -y libsecret-1-0 libsecret-1-dev" "(13) 라이브러리 설치"
cmdRun "cd /usr/share/doc/git/contrib/credential/libsecret ; sudo make" "(14) 컴파일"
cmdRun "git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret" "(15) 설치"
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
cmdYenter "git config credential.helper store" "(16) 이와 같이 저장합니다."


# ----
rm -f ${zz00log_name} ; zz00log_name="${zz00logs_folder}/zz.$(date +"%y%m%d%a-%H%M%S")..${CMD_NAME}" ; touch ${zz00log_name}
ls --color ${zz00logs_folder}
cat <<__EOF__
${cRed}<<<<<<<<<<${cBlue} $0 ${cRed}||| ${cMagenta}${MEMO} ${cRed}<<<<<<<<<<${cReset}
__EOF__
