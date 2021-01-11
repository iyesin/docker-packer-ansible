FROM alpine:3.12 AS builder

ENV PACKER_VERSION=1.6.6
ENV HASHICORP_KEY_SIG='91A6 E7F8 5D05 C656 30BE F189 5185 2D87 348F FC4C'

RUN apk add --update gnupg

ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS.sig \
    https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS \
    https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip /

RUN gpg --keyserver pool.sks-keyservers.net --receive-keys "${HASHICORP_KEY_SIG}" \
    && gpg --verify "/packer_${PACKER_VERSION}_SHA256SUMS.sig" "/packer_${PACKER_VERSION}_SHA256SUMS" \
    && sed -i '/.*linux_amd64.zip/!d' "/packer_${PACKER_VERSION}_SHA256SUMS" \
    && sha256sum -cs "/packer_${PACKER_VERSION}_SHA256SUMS" \
    && unzip "/packer_${PACKER_VERSION}_linux_amd64.zip" -d /bin


FROM alpine:3.12 AS runner

WORKDIR /

COPY --from=builder bin/packer bin/packer

RUN apk --no-cache upgrade \
    && apk add --no-cache sudo openssh-client docker-py yaml \
                py3-pip py3-ipaddress py3-jinja2 py3-paramiko py3-pycryptodome \
                py3-websocket-client py3-yaml \
    && python3 -m pip install --upgrade pip \
    && python3 -m pip install awscli ansible \
    && rm -rf /var/cache/* /root/.cache \
    && find / -name '__pycache__' -print0 | xargs -0 -- rm -rf

ENTRYPOINT ["/bin/packer"]
