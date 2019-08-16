FROM debian:buster

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y build-essential libssl-dev unzip awscli wget python curl git jq bc

ENV INSIDE_DOCKER=1

ENV GOLANG_VER="1.12.7"
RUN wget -nv https://dl.google.com/go/go${GOLANG_VER}.linux-amd64.tar.gz
RUN tar -xf go${GOLANG_VER}.linux-amd64.tar.gz
RUN mv go /usr/local
RUN mkdir -p /golang
RUN echo 'export GOPATH=/golang' >> ~/.profile
RUN echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> ~/.profile

ENV PACKER_VER="1.4.2"
RUN wget -nv https://releases.hashicorp.com/packer/${PACKER_VER}/packer_${PACKER_VER}_linux_amd64.zip
RUN unzip packer_${PACKER_VER}_linux_amd64.zip
RUN mv packer /usr/local/bin

ENV TERR_VER="0.12.6"
RUN wget -nv https://releases.hashicorp.com/terraform/${TERR_VER}/terraform_${TERR_VER}_linux_amd64.zip
RUN unzip terraform_${TERR_VER}_linux_amd64.zip
RUN mv terraform /usr/local/bin

ENV WRK_VER="4.1.0"
RUN wget -nv -O wrk-4.1.0.zip https://github.com/wg/wrk/archive/${WRK_VER}.zip
RUN unzip wrk-${WRK_VER}.zip
RUN cd wrk-${WRK_VER} && make 2>&1 >/dev/null && mv wrk /usr/local/bin

WORKDIR /workspace
COPY api /workspace/api
COPY infras /workspace/infras
COPY Makefile ssh_keys* /workspace/