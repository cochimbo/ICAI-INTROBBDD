FROM mysql:8.1.0 AS introbbddicade

ENV MYSQL_ROOT_PASSWORD comillas
ENV MYSQL_CHARSET=utf8mb4
ENV MYSQL_COLLATION=utf8mb4_general_ci

COPY ./Empleados/tcentr.txt /var/lib/mysql-files/tcentr.txt
COPY ./Empleados/tdepto.txt /var/lib/mysql-files/tdepto.txt
COPY ./Empleados/temple.txt /var/lib/mysql-files/temple.txt
COPY ./Empleados/empleados.sql /empleados.sql

COPY ./Autobuses /