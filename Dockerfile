FROM python:3.7-alpine3.10
# Do not buffer log messages in memory; some messages can be lost otherwise
ENV PYTHONUNBUFFERED 1

RUN apk update
RUN python -m pip install --upgrade pip

RUN apk add --no-cache postgresql-libs bash openldap-dev &&\
    apk add --no-cache --virtual .build-deps git python-dev gcc musl-dev postgresql-dev libffi-dev libressl-dev libpython3-dev

COPY ./requirements/base.txt requirements/base.txt
COPY ./requirements/production.txt requirements/production.txt
RUN pip install --upgrade pip && pip install -r requirements/production.txt --no-cache-dir

ADD . /code


# RUN apt-get update && \
#     DEBIAN_FRONTEND=noninteractive apt-get install nginx -y

# ADD docker/etc/nginx/tables.conf /etc/nginx/conf.d/tables.conf


# Collecting static files
RUN ./scripts/collectstatic.sh

RUN apk del .build-deps

EXPOSE 8080


ENTRYPOINT ["/code/docker-entrypoint.sh"]
