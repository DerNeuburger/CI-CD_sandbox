FROM nginx:1.7.6
COPY webpage/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]