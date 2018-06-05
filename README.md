# daloRADIUS docker image

A daloRADIUS docker image configurable via environment variables.

## Building

This container must be built from a clone of this repository (or any valid fork), as git is used in the container to perform patches that allow it to be configured using environment variables. The ``--recursive`` flag must be used when cloning, as the ``daloradius`` submodule contains the necessary files to install daloRADIUS on the container. If that is checked, the usual ``docker build -t "daloradius" .`` should do it.

#### For example

```bash
IMAGE_NAME="daloradius"
# Cloning from a local git repo
REPO_ORIGIN="./docker-daloradius.git"
git clone --recursive "$REPO_ORIGIN" ./daloradius-docker
cd ./daloradius-docker
docker build -t "$IMAGE_NAME" .
```

## Running

### Environment configuration

| Variable name      | Description                                            | Default value |
|:-------------------|:-------------------------------------------------------|:--------------|
| ``RADIUS_DB_HOST`` | Hostname or address for the MySQL server               | _error_       |
| ``RADIUS_DB_PORT`` | Port of the MySQL server                               | ``3306``      |
| ``RADIUS_DB_NAME`` | Name of the radius database                            | _error_       |
| ``RADIUS_DB_USER`` | Username for a user with access to the radius database | _error_       |
| ``RADIUS_DB_PASS`` | Password for that user                                 | _error_       |

Ports ``80`` and ``443`` are exposed, you need to publish the ones you need. The variables that _error_ by default must be provided to the container on initialization.

#### For example

```bash
IMAGE_NAME="daloradius"
docker run  -itd \
    --name daloradius \
    -e RADIUS_DB_HOST=myslq \
    -e RADIUS_DB_USER=freeradius \
    -e RADIUS_DB_PASS=radpass \
    -e RADIUS_DB_NAME=freeradius \
    -p 8080:80 \
    "$IMAGE_NAME"
```
This will create a container running detached with TTY, named ``daloradius`` from the image ``$IMAGE_NAME`` that accesses a MySQL server with hostname ``myslq`` (at the default port), as user ``freeradius`` with password ``radius`` to the database named ``freeradius``, that then publishes the internal port ``80`` to the port ``8080``.

### Database initialization

Scripts for initializing the MySQL database can be found on the ``contrib/db/`` directory of the daloRADIUS project, or in the ``/var/www/html/contrib/db/`` directory of this image.

#### For example

Say you have a mysql container that servers as a datastore for a freeRADIUS installation, in that case you can initialize the database with these commands.

```bash
# Usually the default script is want you want
DB_SCRIPT="mysql-daloradius.sql"
DR_CONTAINER_NAME="daloradius"
MYSQL_CONTAINER_NAME="mysql"
DB_USER="freeradius"
DB_PASS="radpass"
DB_NAME="freeradius"

docker exec "$DR_CONTAINER_NAME" \
    cat "/var/www/html/contrib/db/$DB_SCRIPT" |
docker exec "$MYSQL_CONTAINER_NAME" \
    mysql \
        "-u${DB_USER}" \
        "-p${DB_PASS}" \
        "$DB_NAME"
```
