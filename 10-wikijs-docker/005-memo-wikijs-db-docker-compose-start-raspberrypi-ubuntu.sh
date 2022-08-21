#!/bin/sh

cat <<__EOF__

독일 사람 게시일2021년 4월 2일 Raspberry Pi에 Docker 및 Docker-Compose를 설치하는 방법 https://dev.to/elalemanyo/how-to-install-docker-and-docker-compose-on-raspberry-pi-1mo
1. 업데이트 및 업그레이드

----> sudo apt-get update && sudo apt-get upgrade
----> press Enter:
__EOF__
read a
sudo apt-get update && sudo apt-get upgrade
cat <<__EOF__

2. 도커 설치

----> curl -sSL https://get.docker.com | sh
----> press Enter:
__EOF__
read a
curl -sSL https://get.docker.com | sh
cat <<__EOF__

3. Docker 그룹에 루트가 아닌 사용자 추가 (굳이 하지 않아도 됨)
Docker 그룹에 사용자를 추가하는 구문은 다음과 같습니다.

sudo usermod -aG docker [user_name]

현재 사용자에게 권한을 추가하려면 다음을 실행하십시오.

sudo usermod -aG docker ${USER}

실행 중인지 확인하십시오.
groups ${USER}
변경 사항을 적용하려면 Raspberry Pi를 재부팅

4. Docker-Compose 설치
Docker-Compose는 일반적으로 pip3를 사용하여 설치됩니다. 이를 위해서는 python3과 pip3가 설치되어 있어야 합니다. 설치하지 않은 경우 다음 명령을 실행할 수 있습니다.

----> sudo apt-get install libffi-dev libssl-dev
----> sudo apt install python3-dev
----> sudo apt-get install -y python3 python3-pip
----> press Enter:
__EOF__
read a
sudo apt-get install libffi-dev libssl-dev
sudo apt install python3-dev
sudo apt-get install -y python3 python3-pip
cat <<__EOF__

python3 및 pip3이 설치되면 다음 명령을 사용하여 Docker-Compose를 설치할 수 있습니다.

----> sudo pip3 install docker-compose
----> press Enter:
__EOF__
read a
sudo pip3 install docker-compose
cat <<__EOF__

5. Docker 시스템 서비스를 활성화하여 부팅 시 컨테이너를 시작합니다.
이것은 매우 훌륭하고 중요한 추가 사항입니다. 다음 명령을 사용하여 부팅할 때마다 Docker 시스템 서비스를 자동으로 실행하도록 Raspberry Pi를 구성할 수 있습니다.

----> sudo systemctl enable docker
----> press Enter:
__EOF__
read a
sudo systemctl enable docker
cat <<__EOF__

이를 통해 재시작 정책 이 항상 또는 중지되지 않는 경우로 설정된 컨테이너 는 재부팅 후 자동으로 다시 시작됩니다.

6. Hello World 컨테이너 실행
Docker가 올바르게 설정되었는지 테스트하는 가장 좋은 방법은 Hello World 컨테이너를 실행하는 것입니다.
이렇게 하려면 다음 명령을 입력하십시오.
docker run hello-world
모든 단계를 거치면 출력에서 ​​설치가 올바르게 작동하는 것으로 나타납니다.

7. 샘플 Docker Compose 파일
이 섹션에서는 Docker-Compose 파일의 빠른 샘플을 보여줍니다. 이 샘플은 Raspberry Pi가 완전히 전원을 껐다 켜면 자동으로 시작되는 세 개의 컨테이너를 시작합니다. 샘플 프로젝트에 대해 자세히 알아보려면 GitHub의 Docker 속도 테스트 프로젝트를 방문 하세요.
version: '3'
services:
  # Tests the current internet connection speed
  # once per hour and writes the results into an
  # InfluxDB instance
  speedtest:    
    image: robinmanuelthiel/speedtest:0.1.1
    restart: always
    depends_on:
      - influxdb
    environment:
      - LOOP=true
      - LOOP_DELAY=3600 # Once per hour
      - DB_SAVE=true
      - DB_HOST=http://influxdb:8086
      - DB_NAME=speedtest
      - DB_USERNAME=admin
      - DB_PASSWORD=<MY_PASSWORD>

  # Creates an InfluxDB instance to store the
  # speed test results
  influxdb:
    image: influxdb
    restart: always
    volumes:
      - influxdb:/var/lib/influxdb
    ports:
      - "8083:8083"
      - "8086:8086"
    environment:
      - INFLUXDB_ADMIN_USER=admin
      - INFLUXDB_ADMIN_PASSWORD=<MY_PASSWORD>
      - INFLUXDB_DB=speedtest

  # Displays the results in a Grafana dashborad
  grafana:
    image: grafana/grafana:latest
    restart: always
    depends_on:
      - influxdb
    ports:
      - 3000:3000
    volumes:
      - grafana:/var/lib/grafana

volumes:
  grafana:
  influxdb:
Docker-Compose를 사용하여 컨테이너를 시작하려면 다음 명령을 실행합니다.

----> sudo docker-compose -f wikijs-files/docker-compose.yml up -d
----> press Enter:
__EOF__
read a
sudo docker-compose -f /home/docker/wiki.js/docker-compose.yml up -d
