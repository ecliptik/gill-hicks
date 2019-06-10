# Gill Hicks

Python Flask app using MySQL backend host.

## Configuration

Configured using Environment Variables

- MYSQL_HOST - Hostname of MySQL Database to use
- MYSQL_USER - MySQL database user name to connect with
- MYSQL_PASSWORD - MySQL password to connect with
- MYSQL_DATABASE - MySQL database to use
- HARDWARE_HOST - Hostname where hardware appliation runs

## Local Deployment

Deploy locally using [docker-compose](https://docs.docker.com/compose/).

```
docker-compose up
```

Connect to http://locahost:5000

## Local Deployment Configuration

Update `docker-compose.yaml` to change configuration values in the `environment`.
