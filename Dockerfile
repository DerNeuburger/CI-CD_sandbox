FROM nginx:alpine
COPY webpage/ /usr/share/nginx/html/
EXPOSE 80