FROM nginx
RUN rm /etc/nginx/conf.d/default.conf
COPY ./app.conf /etc/nginx/conf.d
COPY ./demo-index.html /usr/share/nginx/html 