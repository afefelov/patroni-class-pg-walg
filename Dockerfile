FROM phusion/baseimage

MAINTAINER Andy Fefelov <andy@mastery.pro>

ENV DEBIAN_FRONTEND noninteractive
ENV PG_MAJOR 9.6

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
RUN apt-get install -y wget ca-certificates sudo
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install --no-install-recommends -y postgresql-server-dev-$PG_MAJOR libpq-dev postgresql-client-$PG_MAJOR

RUN apt-get update && apt-get install -y htop vim iftop iotop iperf net-tools iputils-ping python-pip postgresql-server-dev-$PG_MAJOR git
RUN pip install pgcli psutil patroni[consul] python-consul dnspython boto mock requests six kazoo click tzlocal prettytable PyYAML

#wal-g staff
RUN wget https://github.com/wal-g/wal-g/releases/download/v0.1.15/wal-g.linux-amd64.tar.gz && tar -zxvf wal-g.linux-amd64.tar.gz && mv wal-g /usr/bin && chmod +x /usr/bin/wal-g && rm wal-g.linux-amd64.tar.gz

#wal-g operational staff
ENV WALG_UPLOAD_DISK_CONCURRENCY 5

ADD restore_command.sh /usr/bin/restore_command.sh
ADD restore_backup.sh /usr/bin/restore_backup.sh

RUN chmod 777 /usr/bin/restore_command.sh
RUN chmod 777 /usr/bin/restore_backup.sh

# patroni staff
RUN mkdir /etc/service/patroni
ADD run-patroni.sh /etc/service/patroni/run

RUN export TERM=xterm
ENV PATH /usr/bin:$PATH
