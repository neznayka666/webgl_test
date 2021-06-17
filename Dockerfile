FROM ubuntu:latest
MAINTAINER Artem Fedoryshyn <artem.fedoryshyn@tmx.com.ua>

#ENV HTTP_PROXY="http://web-server:8080"	


RUN apt-get update
RUN apt-get -y upgrade

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2

COPY ./mime.conf /etc/apache2/mods-enabled/mime.conf
COPY ./mime.types /etc/mime.types
COPY ./html /var/www/html

RUN apt-get install brotli
RUN apt install brotli
RUN apt-get install apache2-dev -y
RUN apt install git -y
RUN git clone --depth=1 --recursive https://github.com/kjdev/apache-mod-brotli.git
RUN cp -r apache-mod-brotli/* .
RUN rm autogen.sh
COPY ./autogen.sh .
RUN  ./autogen.sh
RUN  ./configure
RUN make
RUN install -D .libs/mod_brotli.so /usr/lib/apache2/modules/mod_brotli.so -m 644
RUN echo "LoadModule brotli_module /usr/lib/apache2/modules/mod_brotli.so" > /etc/apache2/mods-available/brotli.load
COPY ./brotli.conf /etc/apache2/mods-available/brotli.conf
RUN a2enmod brotli
COPY ./000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY ./ports.conf /etc/apache2/ports.conf
RUN service apache2 restart

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80
EXPOSE 1433
EXPOSE 9090
EXPOSE 8080
EXPOSE 2100
EXPOSE 9091
CMD /usr/sbin/apache2ctl -D FOREGROUND
