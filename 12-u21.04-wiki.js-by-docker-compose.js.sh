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
if [[ "x$CMD_DIR" == "x" ]] || [[ "x$CMD_DIR" == "x$CMD_NAME" ]]; then
	CMD_DIR="."
fi

# ----------
MEMO="docker-compose wiki.js 출처: https://wiki.js.org/"
echo "${cYellow}>>>>>>>>>>${cGreen} $0 ||| ${cCyan}${MEMO} ${cYellow}>>>>>>>>>>${cReset}"
# ----------

etherNet_port="8899"
wifi_port="4455"

out_str="$(ifconfig)"
#-- if [[ "${out_str}" =~ "inet" ]]; then
if [ "x${out_str}" = "x" ]; then
	cat_and_run "sudo apt install net-tools" "#-- ifconfig 가 없으므로, 새로 설치합니다."
fi

cat_and_run "ifconfig | grep -B1 inet\ "
cat <<__EOF__

1 ..... ether net port [ ${etherNet_port} ]
2 ..... wifi port [ ${wifi_port} ]

----> 1, 2 또는 포트번호를 직접 지정하세요.
__EOF__
read a ; echo "${cUp}"
if [ "x$a" = "x1" ]; then
	port_no="${etherNet_port}"
else
	if [ "x$a" = "x2" ]; then
		port_no="${wifi_port}"
	else
		if [ "x$a" = "x" ]; then
			port_no="${etherNet_port}"
		else
			port_no="$a"
		fi
	fi
fi
echo "${cRed}[ ${cReset}${a} ${cRed}] ${cYellow}${port_no}${cReset}"

DB_FOLDER=/home/docker-data/postgresql
if [ ! -d ${DB_FOLDER} ]; then
	echo "----> ${cGreen}sudo mkdir -p ${DB_FOLDER}${cReset}"
	sudo mkdir -p ${DB_FOLDER}
	cat_and_run "sudo chcon -R system_u:object_r:container_file_t:s0 ${DB_FOLDER}"
	#-- cat_and_run "sudo chown -R systemd-coredump.ssh_keys ${DB_FOLDER}"
	cat_and_run "ls -lZ ${DB_FOLDER}" "디렉토리를 만들었습니다."
fi

wiki_dir="${HOME}/projects-$(uname -n)/wiki.js"
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

cat_and_run "sudo docker ps -a"
cat_and_run "sudo docker-compose pull wiki"

cat_and_run "sudo docker-compose ps" "#-- 실행중인 작업을 확인한다."
cat_and_run "ifconfig | grep enp -A1 ; ifconfig | grep wlp -A1" "#-- ip 를 확인한다."
cat_and_run "ifconfig | grep enp -A1 | tail -1 | awk '{print \$2\":${port_no}\"}'" "#-- ethernet"
cat_and_run "ifconfig | grep wlp -A1 | tail -1 | awk '{print \$2\":${port_no}\"}'" "#-- wifi"
cat_and_run "sudo docker-compose up --force-recreate &"
cat_and_run "sudo docker-compose ps -a" "#-- 모든 작업을 확인한다."

cat  <<__EOF__
${cCyan}# -------------------------------------
sudo docker-compose down # ---- 작업을 중단할때, 현재의 디렉토리에서 입력한다.
localhost:${port_no} # ---- 위키서버가 실행되면 브라우저에서 이와같이 입력한다.
# -------------------------------------
__EOF__

cd -
cat_and_run "ls --color ${CMD_DIR}"
echo "${cYellow}>>>>>>>>>>${cGreen} $0 ||| ${cCyan}${MEMO} ${cYellow}>>>>>>>>>>${cReset}"
