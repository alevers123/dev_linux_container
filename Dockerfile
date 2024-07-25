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
   build-essential\
   iproute2\
   vifm
ARG uname
ARG uid
ARG gid
#RUN mkdir /home/$uname
#VOLUME /home/$uname
COPY ./scripts /opt/scripts
RUN locale-gen en_US.UTF-8
RUN userdel ubuntu
RUN addgroup --gid $gid $uname
RUN adduser --gecos "" --home /home/$uname --shell /bin/zsh --uid $uid --gid $gid $uname && adduser \
$uname sudo && passwd -d $uname && chown -R $uname:$uname /home/$uname && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> \
/etc/sudoers
USER $uname
RUN bash /opt/scripts/setup.sh $uname
WORKDIR /home/$uname
ENTRYPOINT ["/bin/zsh"]
