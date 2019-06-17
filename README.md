# ORQUESTRAÇÃO COM DOCKER-COMPOSE

Criação de uma POC de banco maysql 5.6 com integração do PhpMyAdmin

---------------------------------------------------------------------------------------

### Pré-requisitos ###

* Docker 
* Docker-compose

### Estrutura do projeto ###
Criar a estrutura de diretórios conforme representado abaixo:
    .
>     ├── docker-compose.yaml
>     ├── mysql
>         ├── Dockerfile
>         └── config
>             └── base.sql

   

### Criar imagem  customizada do mysql 5.6 ###

 <p>Para nosso projeto de estudo, iremos  criar a imagem do mysql já embarcado com o sql de criação do banco de dados, com suas tabelas.</p> 
 Assim, criaremos o arquivo Dockerfile como todas as configurações necessárias.
 

### Conteúdo do arquivo Dockerfile
 
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

### Conteúdo arquivo base.sql ###

    CREATE DATABASE CADASTRO;
    ;;
    use CADASTRO
    ;;
    CREATE TABLE IF NOT EXISTS CONTATO (
    NOME VARCHAR(20),
    TELEFONE VARCHAR(9),
    DATA_NASC DATE,
    EMAIL VARCHAR(30)
    )ENGINE=MyISAM;
    ;;
    INSERT INTO CONTATO (NOME,TELEFONE,DATA_NASC,EMAIL) VALUES('IGOR FRAZZON', '981447368','1984-01-15','igor.frazzon@gmail.com');
    
 
### Gerar imagem customizada com nome mysql-condors:5.6
 Executar o comando no mesmo local que está o Dockerfile
    
    docker build --build-arg pwdMysql=condors -t mysql-condors:5.6 .
    
### Executar o contêiner criado no passo anterior ###
    
    docker container run -d --rm --name  container-mysql mysql-condors:5.6
    
### Verificar log contêiner ###

    docker logs container-mysql
### Resultado do do comando acima ###

    2019-06-11 20:11:45 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
    2019-06-11 20:11:45 0 [Note] mysqld (mysqld 5.6.44) starting as process 1 ...
    2019-06-11 20:11:45 1 [Note] Plugin 'FEDERATED' is disabled.
    2019-06-11 20:11:45 1 [Note] InnoDB: Using atomics to ref count buffer pool pages
    2019-06-11 20:11:45 1 [Note] InnoDB: The InnoDB memory heap is disabled
    2019-06-11 20:11:45 1 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
    2019-06-11 20:11:45 1 [Note] InnoDB: Memory barrier is not used
    2019-06-11 20:11:45 1 [Note] InnoDB: Compressed tables use zlib 1.2.11
    2019-06-11 20:11:45 1 [Note] InnoDB: Using Linux native AIO
    2019-06-11 20:11:45 1 [Note] InnoDB: Using CPU crc32 instructions
    2019-06-11 20:11:45 1 [Note] InnoDB: Initializing buffer pool, size = 128.0M
    2019-06-11 20:11:45 1 [Note] InnoDB: Completed initialization of buffer pool
    2019-06-11 20:11:45 1 [Note] InnoDB: Highest supported file format is Barracuda.
    2019-06-11 20:11:45 1 [Note] InnoDB: 128 rollback segment(s) are active.
    2019-06-11 20:11:45 1 [Note] InnoDB: Waiting for purge to start
    2019-06-11 20:11:45 1 [Note] InnoDB: 5.6.44 started; log sequence number 1625997
    2019-06-11 20:11:45 1 [Note] Server hostname (bind-address): '*'; port: 3306
    2019-06-11 20:11:45 1 [Note] IPv6 is available.
    2019-06-11 20:11:45 1 [Note]   - '::' resolves to '::';
    2019-06-11 20:11:45 1 [Note] Server socket created on IP: '::'.
    2019-06-11 20:11:45 1 [Warning] Insecure configuration for --pid-file: Location '/var/run/mysqld' in the path is accessible to all OS users. Consider choosing a different directory.
    2019-06-11 20:11:45 1 [Warning] 'proxies_priv' entry '@ root@54d220f4126d' ignored in --skip-name-resolve mode.
    2019-06-11 20:11:46 1 [Note] Event Scheduler: Loaded 0 events
    2019-06-11 20:11:46 1 [Note] mysqld: ready for connections.
    Version: '5.6.44'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server (GPL)
    
### Testar o novo conteiner executando comando sql ###
   
    docker run -it --rm --link container-mysql mysql:5.6 mysql -hcontainer-mysql -uroot -pcondors CADASTRO -e "select * from CONTATO;"

### Retorno do comando SELECT ###

    +--------------+-----------+------------+------------------------+
    | NOME         | TELEFONE  | DATA_NASC  | EMAIL                  |
    +--------------+-----------+------------+------------------------+
    | IGOR FRAZZON | 981447368 | 1984-01-15 | igor.frazzon@gmail.com |
    +--------------+-----------+------------+------------------------+

De acordo com o retorno do comando, verficamos que está tudo ok, e podemos passar para o passo de orquestrar no ambiente com o docker-compose.
É necessário criar o arquivo docker-compose.yaml com o conteúdo abaixo:
### Conteúdo do arquivo docker-compose.yaml

    version: '3.3'
    services:
      db:
        image: mysql-condors:5.6
        ports:
          - "3306:3306"
        volumes:
          - data:/var/lib/mysql
        networks:
          - network-mysql
      app:
        image: phpmyadmin/phpmyadmin:latest
        links:
          - db
        ports:
          - 80:80
        environment:
          - PMA_ARBITRARY=1
        networks:
          - network-mysql
    
    networks:
       network-mysql:
    
    volumes:
      data:

Agora para realizar o deploy do projeto, é necessário executar o comando abaixo:

    docker-compose up -d
    
    
### Acessando  a url do PhpMyadmin ###

 http://localhost
 
Informar o usuário: root e senha: condors

  