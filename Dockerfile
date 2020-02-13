FROM golang:alpine
MAINTAINER "Wojciech Puchta <wojciech.puchta@hicron.com>"

ENV TERRAFORM_VERSION=0.11.7
ENV AWS_CLI_VERSION=1.17.12
ENV HELM_VERSION=2.16.1
ENV HELM_SHA256=7eebaaa2da4734242bbcdced62cc32ba8c7164a18792c8acdf16c77abffce202
ENV TF_DEV=true
ENV TF_RELEASE=true

WORKDIR $GOPATH/src/github.com/hashicorp/terraform

# install cli tools
RUN apk update \
  && apk add bash py-pip make git openssh vim curl jq \
  && apk add --virtual=build gcc libffi-dev musl-dev openssl-dev python-dev \

# install azure cli
  && pip install azure-cli \
  && apk del --purge build \

# install terraform
  && git clone https://github.com/hashicorp/terraform.git ./ \
  && git checkout v${TERRAFORM_VERSION} \
  && /bin/bash scripts/build.sh \

# install aws cli
  && pip install awscli==${AWS_CLI_VERSION} boto3 --upgrade \

# install AzCopy
  && apk add libc6-compat \
  && wget https://aka.ms/downloadazcopy-v10-linux -O /tmp/azcopy \
  && tar -zxvf /tmp/azcopy -C /tmp/ \
  && mv /tmp/azcopy_linux_amd64*/azcopy /bin/azcopy \

# install kubectl
  && wget https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/amd64/kubectl \
  && chmod +x kubectl \
  && mv kubectl /usr/local/bin/ \

# install Helm
  && wget https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
  && echo "${HELM_SHA256}  helm-v${HELM_VERSION}-linux-amd64.tar.gz" | sha256sum -c - \
  && tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
  && mv linux-amd64/helm /usr/local/bin \
  && rm -rf helm-v*-linux-amd64.tar.gz linux-amd64

COPY .bashrc /root/.bashrc
COPY ssh_config /etc/ssh/ssh_config

WORKDIR /root
CMD /bin/bash
