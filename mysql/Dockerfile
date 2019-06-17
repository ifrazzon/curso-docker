FROM mysql:5.6 as builder

ARG pwdMysql

#  Esse arquivo faz a inicialização do banco de dados, mas também executa o daemon mysql, removendo a última linha.
RUN ["sed", "-i", "s/exec \"$@\"/echo \"not running $@\"/", "/usr/local/bin/docker-entrypoint.sh"]

# necessário para inicialização
ENV MYSQL_ROOT_PASSWORD="${pwdMysql}"

COPY config/base.sql /docker-entrypoint-initdb.d/

RUN ["/usr/local/bin/docker-entrypoint.sh", "mysqld", "--datadir", "/initialized-db"]

FROM mysql:5.6

COPY --from=builder /initialized-db /var/lib/mysql
