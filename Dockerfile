FROM nginx:alpine

COPY files/nginx.conf /etc/nginx/
COPY files/start.sh start.sh

EXPOSE 8080