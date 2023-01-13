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

CMD_NAME=`basename $0` # 명령줄에서 실행 프로그램 이름만 꺼냄
CMD_DIR=${0%/$CMD_NAME} # 실행 이름을 빼고 나머지 디렉토리만 담음
if [ "x$CMD_DIR" == "x" ] || [ "x$CMD_DIR" == "x$CMD_NAME" ]; then
	CMD_DIR="."
fi
logs_folder="${HOME}/zz00logs" ; if [ ! -d "${logs_folder}" ] ; then mkdir "${logs_folder}" ; fi

# ----------
MEMO="Docker+compose in ubuntu 20.04 https://cholee714.tistory.com/30"
echo "${cYellow}>>>>>>>>>>${cGreen} $0 ||| ${cCyan}${MEMO} ${cYellow}>>>>>>>>>>${cReset}"
# ----------

cat <<__EOF__
+---+
| 1 | Docker
+---+
__EOF__
#-xx "sudo apt update -y && apt upgrade -y ; sudo apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release"
#xxxx cat_and_run "sudo apt update -y" #-xx && sudo apt upgrade -y #-- 양이 많아서 제외한다.
cat_and_run "sudo apt update -y && sudo apt upgrade -y"
cat_and_run "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common"
#-xx "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg"
cat_and_run "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
#-xx "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null"
cat_and_read "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\""
cat_and_read "sudo apt-get update -y && sudo apt-get install -y docker-ce docker-ce-cli containerd.io"
cat_and_run "sudo docker -v"
cat_and_run "sudo systemctl enable docker && sudo service docker start"
cat_and_run "sudo service docker status"

cat <<__EOF__
+---+
| 2 | Docker-compose
+---+
__EOF__
cat_and_run "sudo curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose"
cat_and_run "sudo chmod +x /usr/local/bin/docker-compose"
cat_and_run "sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose"
cat_and_run "docker-compose -version"

cat <<__EOF__
다음 사이트에서 최신 버젼을 확인한다.
https://github.com/docker/compose/releases #-- 오른쪽 마우스로 클릭해서 링크열기 하면된다.
__EOF__

cat <<__EOF__
+---+
| 3 | Install Jekyll
+---+
__EOF__
jekyll_dir="${HOME}/jekyll"
if [ ! -d ${jekyll_dir} ]; then
	cat_and_run "mkdir ${jekyll_dir}"
fi

echo "----> cd ${jekyll_dir}"
cd ${jekyll_dir}

cat > docker-compose.yml <<__EOF__
version: "3.3"
services:
  site:
    command: jekyll serve
    image: jekyll/jekyll:latest
    volumes:
      - $PWD:/srv/jekyll
      - $PWD/vendor/bundle:/usr/local/bundle
    ports:
      - 4000:4000
      - 35729:35729
      - 3000:3000
      -   80:4000
__EOF__

cat_and_run "sudo docker-compose run site jekyll new mysite"

cat_and_run "ls --color ${CMD_DIR} ; ls -l --color ${logs_folder}"
echo "${cYellow}>>>>>>>>>>${cGreen} $0 ||| ${cCyan}${MEMO} ${cYellow}>>>>>>>>>>${cReset}"
