FROM python:3.7-slim AS base
LABEL maintainer="Micheal Waltz <docker@accounts.ecliptik.com>"

#Application directory
WORKDIR /app

#Environment settings
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1

#Install runtime deps
RUN apt update && apt install --no-install-recommends -y \
      mariadb-client-core-10.1

#Build image
FROM base AS build

#Install build deps
RUN apt update && apt install --no-install-recommends -y \
    build-essential \
    python-dev \
    libffi-dev \
    zlib1g-dev \
    python3-pip \
    python3-dev \
    python3-setuptools

# Requirements have to be pulled and installed here, otherwise caching won't work
COPY ./requirements.txt /var/tmp/
RUN pip3 install --no-cache-dir -r /var/tmp/requirements.txt

#Run image
FROM base AS run

#Copy files from build image
COPY --from=build /usr/local/ /usr/local/

#Copy app
COPY . /app

#Run as non-root user
RUN chown -R daemon:daemon /app/
USER daemon

#Service ports
EXPOSE 5000
EXPOSE 5001

#Entrypoint for apps, has two apps: dashboard and hardware
ENTRYPOINT ["python"]
CMD ["portal.py"]
