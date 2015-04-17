FROM ubuntu:14.04

RUN apt-get -y update \
    && apt-get -y install nginx-extras

VOLUME [ "/var/log/nginx", "/var/cache/nginx" ]

EXPOSE 80 443

#htdocs folder: /usr/share/nginx/html/

CMD ["nginx", "-g", "daemon off;"]
