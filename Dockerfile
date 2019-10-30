FROM phusion/baseimage

MAINTAINER Andy Fefelov <andy@mastery.pro>

ENV DEBIAN_FRONTEND noninteractive
ENV PG_MAJOR 11

RUN apt-get update && apt-get install -y ca-certificates wget sudo

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN apt-get update
RUN apt-get upgrade -y

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/* \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && apt-get purge -y --auto-remove ca-certificates

RUN apt-get update \
    && apt-get install -y postgresql-common \
    && sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf \
    && apt-get install -y \
        postgresql-$PG_MAJOR\
        postgresql-contrib-$PG_MAJOR


RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql

RUN apt-get install --no-install-recommends -y libpq-dev postgresql-client-$PG_MAJOR

RUN apt-get update && apt-get install -y htop vim iftop iotop iperf net-tools iputils-ping python-pip postgresql-server-dev-$PG_MAJOR git

RUN pip install psutil patroni[consul] python-consul dnspython boto mock requests six kazoo click tzlocal prettytable PyYAML

#wal-g staff
RUN wget https://github.com/wal-g/wal-g/releases/download/v0.1.15/wal-g.linux-amd64.tar.gz && tar -zxvf wal-g.linux-amd64.tar.gz && mv wal-g /usr/bin && chmod +x /usr/bin/wal-g && rm wal-g.linux-amd64.tar.gz

#wal-g operational staff
ENV WALG_S3_STORAGE_CLASS STANDARD_IA
ENV WALG_COMPRESSION_METHOD lzma
ENV WALG_UPLOAD_DISK_CONCURRENCY 5

ADD archive_command.sh /usr/bin/archive_command.sh
ADD perform_backup.sh /usr/bin/perform_backup.sh
ADD restore_command.sh /usr/bin/restore_command.sh
ADD restore_backup.sh /usr/bin/restore_backup.sh

RUN chmod 777 /usr/bin/restore_command.sh
RUN chmod 777 /usr/bin/restore_backup.sh
RUN chmod 755 /usr/bin/archive_command.sh
RUN chmod 755 /usr/bin/perform_backup.sh

# patroni staff
RUN mkdir /etc/service/patroni
ADD run-patroni.sh /etc/service/patroni/run
RUN chmod 755 /etc/service/patroni/run

RUN export TERM=xterm

ENV PATH /usr/bin:$PATH
ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data