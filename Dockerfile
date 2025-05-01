

FROM ubuntu:oracular

RUN apt update 
RUN apt install -y \
    curl \
    git \
    gnome-terminal \
    ca-certificates\
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*


##########################
## Docker install stuff ##
##########################
RUN for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove $pkg; done || true

RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc

RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*
##########################
## Docker install stuff ##
##########################

RUN apt upgrade

RUN echo -e '\n\
    # tab completion for git \n\
    if [ -f /usr/share/bash-completion/completions/git ]; then\n\
        . /usr/share/bash-completion/completions/git\n\
    fi\n\
        \n\
    # Changes command line look\n\
    parse_git_branch() {\n\
    git branch 2> /dev/null | sed -e '\''/^[^*]/d'\'' -e '\''s/* \\(.*\\)/(\\1)/'\''\n\
    }\n\
        \n\
    PS1='\''${debian_chroot:+($debian_chroot)}\\[\\033[01;32m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[01;31m\\]$(parse_git_branch)\\[\\033[00m\\]\\$ '\''\n\
    ' >> ~/.bashrc