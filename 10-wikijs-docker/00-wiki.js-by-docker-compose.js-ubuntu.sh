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
MEMO="docker-compose wiki.js 설치"
cat <<__EOF__
${cMagenta}>>>>>>>>>>${cGreen} $0 ${cMagenta}||| ${cCyan}${MEMO} ${cMagenta}>>>>>>>>>>${cReset}
출처: https://computingforgeeks.com/install-and-use-docker-compose-on-fedora/
__EOF__
logs_folder="${HOME}/zz00logs" ; if [ ! -d "${logs_folder}" ]; then cat_and_run "mkdir ${logs_folder}" ; fi
log_name="${logs_folder}/zz.$(date +"%y%m%d-%H%M%S")__RUNNING_${CMD_NAME}" ; touch ${log_name}
# ----

port_no="5800"

DB_FOLDER=/home/docker/pgsql
if [ ! -d ${DB_FOLDER} ]; then
	echo "----> ${cGreen}sudo mkdir -p ${DB_FOLDER}${cReset}"
	sudo mkdir -p ${DB_FOLDER}
	cat_and_run "ls -lZ ${DB_FOLDER}" "폴더를 만들었습니다."
else
	echo "${cRed}!!!!${cMagenta} ----> ${cCyan}${DB_FOLDER}${cReset} 디렉토리가 있으므로, 진행을 중단합니다."
	exit 1
fi

wiki_dir="${PWD}/wikijs-files"
if [ ! -d ${wiki_dir} ]; then
	mkdir -p ${wiki_dir}
fi
cd ${wiki_dir}

cat > docker-compose.yml <<__EOF__
version: "3"
services:

  db:
    image: postgres:11-alpine
    environment:
      POSTGRES_DB: wiki
      POSTGRES_PASSWORD: wikijsrocks
      POSTGRES_USER: wikijs
    logging:
      driver: "none"
    restart: unless-stopped
    volumes:
      - ${DB_FOLDER}:/var/lib/postgresql/data
    container_name:
      wikijsdb

  wiki:
    image: requarks/wiki:2
    depends_on:
      - db
    environment:
      DB_TYPE: postgres
      DB_HOST: db
      DB_PORT: 5432
      DB_USER: wikijs
      DB_PASS: wikijsrocks
      DB_NAME: wiki
    restart: unless-stopped
    ports:
      - "${port_no}:3000"
    container_name:
      wikijs
__EOF__

cat <<__EOF__
+---+
| 1 | Docker
+---+
Ubuntu 22.04에서 Docker를 설치하고 사용하는 방법 2022년 4월 26일에 게시됨
FROM: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04
__EOF__
cat_and_run "sudo apt -y update && sudo apt -y upgrade" "(1) 먼저 기존 패키지 목록을 업데이트합니다." #-- "upgrade 는 양이 많아서 제외한다."

cat_and_run "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common" "(2) HTTPS를 통해 패키지를 사용할 수 있는 몇 가지 필수 패키지를 설치합니다."
#--- cat_and_run "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common"

cat_and_run "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg" "(3) 공식 Docker 리포지토리의 GPG 키를 시스템에 추가합니다."
#--- "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg"

cat <<__EOF__
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
(4) APT 소스에 Docker 리포지토리를 추가합니다.
__EOF__
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

cat_and_run "sudo apt update" "(5) 추가가 인식되도록 기존 패키지 목록을 다시 업데이트하십시오."

cat_and_run "apt-cache policy docker-ce" "(6) 기본 Ubuntu 리포지토리 대신 Docker 리포지토리에서 설치하려고 하는지 확인합니다."
cat <<__EOF__
(7) Docker의 버전 번호는 다를 수 있지만 다음과 같은 출력이 표시됩니다.

apt-cache policy docker-ce의 출력
docker-ce:
  Installed: (none)
  Candidate: 5:20.10.14~3-0~ubuntu-jammy
  Version table:
     5:20.10.14~3-0~ubuntu-jammy 500
        500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
     5:20.10.13~3-0~ubuntu-jammy 500
        500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
docker-ce이 설치되지 않았지만 설치 후보는 Ubuntu 22.04(jammy)용 Docker 리포지토리에서 가져온 것 입니다.
__EOF__

#--- cat_and_run "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
#--- "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null"

cat_and_run "sudo apt-get update -y && sudo apt-get install -y docker-ce docker-ce-cli containerd.io" "(8)"
cat_and_run "sudo docker -v" "(9)"
cat_and_run "sudo systemctl enable docker && sudo service docker start" "(10)"
cat_and_run "sudo service docker status" "(11)"

cat <<__EOF__
+---+
| 2 | Docker-compose
+---+
__EOF__
docker_compose_version=2.14.0
today_y2m2d2=221215
echo "#--- https://github.com/docker/compose/releases ----> ${docker_compose_version} ----> ${today_y2m2d2}"
cat_and_run "sudo curl -L https://github.com/docker/compose/releases/download/v${docker_compose_version}/docker-compose-linux-$(uname -m) -o /usr/local/bin/docker-compose" "(12)"
cat_and_run "sudo chmod +x /usr/local/bin/docker-compose" "(13)"
cat_and_run "sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose" "(14)"
cat_and_run "docker-compose --version" "(15)"

cat <<__EOF__
다음 사이트에서 최신 버젼을 확인한다.
https://github.com/docker/compose/releases #-- 오른쪽 마우스로 클릭해서 링크열기 하면된다.
__EOF__

cat_and_run "ifconfig | grep enp -A1 ; ifconfig | grep wlp -A1" "(16) ip 를 확인합니다."
cat_and_run "ifconfig | grep enp -A1 | tail -1 | awk '{print \$2\":${port_no}\"}'" "(17) ethernet"
cat_and_run "ifconfig | grep wlp -A1 | tail -1 | awk '{print \$2\":${port_no}\"}'" "(18) wifi"
cat_and_run "sudo docker-compose up --force-recreate &" "(19)"
cat_and_run "sudo docker-compose ps -a" "(20) 모든 작업을 확인합니다."

cd -

# ----
rm -f ${log_name} ; log_name="${logs_folder}/zz.$(date +"%y%m%d-%H%M%S")..${CMD_NAME}" ; touch ${log_name}
cat_and_run "ls --color ${CMD_DIR}" ; ls --color ${logs_folder}
echo "${cRed}<<<<<<<<<<${cBlue} $0 ${cRed}||| ${cMagenta}${MEMO} ${cRed}<<<<<<<<<<${cReset}"

cat  <<__EOF__
${cCyan}#--- 출처: https://wiki.js.org/
${cRed}+----------------+${cReset}
${cRed}|                |${cReset}
${cRed}| ${cReset}localhost:${port_no} ${cRed}| ${cGreen}#--- 위키서버가 실행되면 브라우저에서 이와같이 입력합니다.
${cRed}|                |${cReset}
${cRed}+----------------+${cReset}
${cCyan}cd ${wiki_dir} ; sudo docker-compose down #--- 작업을 중단할때, 입력합니다. ${cReset}
__EOF__
