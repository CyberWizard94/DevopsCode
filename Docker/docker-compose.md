What is docker-compose?

Docker Compose is a tool you can use to define and share multi-container applications. This means you can run a project with multiple containers using a single source.

For example, assume you're building a project with NodeJS and MongoDB together. You can create a single image that starts both containers as a service – you don't need to start each separately.

docker-compose.yml file

The compose file is a YML file defining services, networks, and volumes for a Docker container. There are several versions of the compose file format available – 1, 2, 2.x, and 3.x.


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
version: '3'
services:
  redis:
    image: redislabs/redismod
    ports:
      - '6379:6379'
  web:
    build:
      context: .
      target: builder
    # flask requires SIGINT to stop gracefully
    # (default stop signal from Compose is SIGTERM)
    stop_signal: SIGINT
    ports:
      - '8000:8000'
    secrets:
      - db-password
    volumes:
      - .:/code
    networks:
      - spring-postgres
    depends_on:
      - redis
  db:
    # We use a mariadb image which supports both amd64 & arm64 architecture
    image: mariadb:10.6.4-focal
    # If you really want to use MySQL, uncomment the following line
    #image: mysql:8.0.27
    command: '--default-authentication-plugin=mysql_native_password'
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - spring-postgres
    secrets:
      - db-password
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=somewordpress
      - MYSQL_DATABASE=wordpress
      - MYSQL_USER=wordpress
      - MYSQL_PASSWORD=wordpress
    expose:
      - 3306
      - 33060
  wordpress:
    image: wordpress:latest
    ports:
      - 80:80
    networks:
      - spring-postgres
    secrets:
      - db-password
    restart: always
    environment:
      - WORDPRESS_DB_HOST=db
      - WORDPRESS_DB_USER=wordpress
      - WORDPRESS_DB_PASSWORD=wordpress
      - WORDPRESS_DB_NAME=wordpress
volumes:
  db_data:
secrets:
  db-password:
    file: db/password.txt
networks:
  spring-postgres:
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Build:
********

The build subsection defines configuration options that are applied by Compose to build Docker images from source. build can be specified either as a string containing a path to the build context or as a detailed structure:

Context:
**********
context defines either a path to a directory containing a Dockerfile, or a URL to a git repository.

When the value supplied is a relative path, it is interpreted as relative to the location of the Compose file. Compose warns you about the absolute path used to define the build context as those prevent the Compose file from being portable.

dockerfile sets an alternate Dockerfile. A relative path is resolved from the build context. Compose warns you about the absolute path used to define the Dockerfile as it prevents Compose files from being portable.

When set, dockerfile_inline attribute is not allowed and Compose rejects any Compose file having both set.


build:
  context: .
  dockerfile: webapp.Dockerfile


dockerfile_inline:
*******************

dockerfile_inline defines the Dockerfile content as an inlined string in a Compose file. When set, the dockerfile attribute is not allowed and Compose rejects any Compose file having both set.

Use of YAML multi-line string syntax is recommended to define the Dockerfile content:


build:
  context: .
  dockerfile_inline: |
    FROM baseimage
    RUN some command 
   
args:
*******

args define build arguments, i.e. Dockerfile ARG values.

args can be set in the Compose file under the build key to define GIT_COMMIT. args can be set as a mapping or a list:

build:
  context: .
  args:
    GIT_COMMIT: cdc3b19
