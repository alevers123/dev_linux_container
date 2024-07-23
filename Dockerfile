FROM ubuntu:latest
RUN apt-get update && apt-get install -y \
   neovim \
   zsh \
   tmux \
   git \
   wget\
   curl\
   sudo\
   locales\
   build-essential
ARG uname
ARG uid
ARG gid
#RUN mkdir /home/$uname
VOLUME /home/$uname
VOLUME /opt/scripts
RUN locale-gen en_US.UTF-8
RUN userdel ubuntu
RUN addgroup --gid $gid $uname
RUN adduser --gecos "" --home /home/$uname --shell /bin/zsh --uid $uid --gid $gid $uname && adduser $uname sudo && passwd -d $uname && chown -R $uname:$uname /home/$uname
USER $uname
WORKDIR /home/$uname
ENTRYPOINT ["/bin/zsh"]
