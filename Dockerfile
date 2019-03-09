FROM httpd:alpine
COPY ./website/ /usr/local/apache2/htdocs/
