FROM python:3.7-alpine3.10
# Do not buffer log messages in memory; some messages can be lost otherwise
ENV PYTHONUNBUFFERED 1

RUN apk update
RUN python -m pip install --upgrade pip

RUN apk add --no-cache postgresql-libs bash openldap-dev &&\
    apk add --no-cache --virtual .build-deps git python-dev gcc musl-dev postgresql-dev libffi-dev libressl-dev

COPY . /code
WORKDIR /code

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install nginx -y

ADD docker/etc/nginx/tables.conf /etc/nginx/conf.d/tables.conf

RUN pip3 install -r requirements/production.txt

EXPOSE 8080

# Collecting static files
RUN ./collectstatic.sh

ARG BRANCH=None
ENV branch=${BRANCH}

ENTRYPOINT ["/code/docker-entrypoint.sh"]
