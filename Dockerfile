FROM debian:stable-slim as verify

# I was trying to this myself but public keys weren't being found properly and then I started basing myself on 
# https://github.com/uphold/docker-litecoin-core/blob/master/0.18/Dockerfile, since they do all the steps asked for in the exercise. Importing 
# this image would also be a valid option, if the vulnerabilities in it were fixed

# download links https://litecoin.org/
# gpg verify instructions, with public key import - https://download.litecoin.org/README-HOWTO-GPG-VERIFY-TEAM-MEMBERS-KEY.txt
RUN apt-get update -y && \
    apt-get install -y wget gnupg && \
    mkdir app && cd app && \
    wget https://download.litecoin.org/litecoin-0.18.1/linux/litecoin-0.18.1-x86_64-linux-gnu.tar.gz && \
    # signature which ensures authenticity and integrity
    wget https://download.litecoin.org/litecoin-0.18.1/linux/litecoin-0.18.1-x86_64-linux-gnu.tar.gz.asc && \
    # https://github.com/docker-library/python/issues/336#issuecomment-421515629
    # apk add gnupg && \
    # add public key corresponding to the private of key of signee
    for key in \
      FE3348877809386C \
    ; do \
      gpg --no-tty --keyserver pgp.mit.edu --recv-keys "$key" || \
      gpg --no-tty --keyserver keyserver.pgp.com --recv-keys "$key" || \
      gpg --no-tty --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
      gpg --no-tty --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ; \
    done && \
    gpg --verify litecoin-0.18.1-x86_64-linux-gnu.tar.gz.asc && \
    # extract files
    tar -xzf litecoin-0.18.1-x86_64-linux-gnu.tar.gz 

# create user entry in passwd file and group as well
# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user + create home directory
RUN groupadd -r litecoin && useradd --no-log-init -mr -g litecoin litecoin && \
    # https://github.com/GoogleContainerTools/distroless/issues/277#issuecomment-456941869
    cd app && echo "litecoin:x:1000:1000:Litecoin service user:/home/litecoin:/bin/sh" > passwd && \
    echo "litecoin:x:1000:litecoin" > group

# following https://sysdig.com/blog/dockerfile-best-practices/
# https://github.com/GoogleContainerTools/distroless/tree/main/cc
FROM gcr.io/distroless/cc:latest

COPY --from=verify /app/passwd /etc/passwd
COPY --from=verify /app/group /etc/group
COPY --from=verify --chown=litecoin:litecoin /home/litecoin /home/litecoin
COPY --from=verify --chown=litecoin:litecoin /app/litecoin-0.18.1/bin/litecoind /bin/litecoind

WORKDIR /home/litecoin

USER litecoin

ENTRYPOINT [ "/bin/litecoind" ]