FROM debian:bullseye-slim
RUN apt-get update && apt upgrade -y && apt-get install -y git python python-setuptools ssh sudo vim
RUN git clone https://github.com/tv42/gitosis.git
WORKDIR /gitosis
COPY id_rsa.pub .
RUN python setup.py install

ARG HOST_UID
ENV HOST_UID=$HOST_UID
ARG HOST_GID
ENV HOST_GID=$HOST_GID
ARG USER
ENV USER=$USER

RUN addgroup --gid "$HOST_GID" $USER
RUN adduser --uid "$HOST_UID" --system --shell /bin/sh --gecos 'gitosis' --disabled-password --ingroup $USER --home /srv/gitosis/ $USER
RUN sudo -H -u $USER gitosis-init <id_rsa.pub

ENTRYPOINT service ssh restart && tail -f /dev/null
