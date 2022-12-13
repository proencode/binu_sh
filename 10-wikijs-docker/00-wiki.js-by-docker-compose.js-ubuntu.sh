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
logs_folder="${HOME}/zz00-logs" ; if [ ! -d "${logs_folder}" ]; then cat_and_run "mkdir ${logs_folder}" ; fi
log_name="${logs_folder}/zz.$(date +"%y%m%d-%H%M%S")__RUNNING_${CMD_NAME}" ; touch ${log_name}
# ----

port_no="5800"

DB_FOLDER=/home/docker/pgsql
if [ ! -d ${DB_FOLDER} ]; then
	echo "----> ${cGreen}sudo mkdir -p ${DB_FOLDER}${cReset}"
	sudo mkdir -p ${DB_FOLDER}
	cat_and_run "sudo chcon -R system_u:object_r:container_file_t:s0 ${DB_FOLDER}"
	cat_and_run "sudo chown -R systemd-coredump.ssh_keys ${DB_FOLDER}"
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
__EOF__
cat_and_run "sudo apt update -y ### && sudo apt upgrade -y" "upgrade 는 양이 많아서 제외한다."
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

cat_and_run "ifconfig | grep enp -A1 ; ifconfig | grep wlp -A1" "(2-2) ip 를 확인합니다."
cat_and_run "ifconfig | grep enp -A1 | tail -1 | awk '{print \$2\":${port_no}\"}'" "(2-3) ethernet"
cat_and_run "ifconfig | grep wlp -A1 | tail -1 | awk '{print \$2\":${port_no}\"}'" "(2-4) wifi"
cat_and_run "sudo docker-compose up --force-recreate &" "(2-5)"
cat_and_run "sudo docker-compose ps -a" "(2-6) 모든 작업을 확인합니다."

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
