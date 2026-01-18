FROM ubuntu:latest
#RUN CODENAME=$(grep -m1 -Po 'ubuntu[^\s]*/\K\w+' /etc/apt/sources.list) && \
#   sed -i "s/${CODENAME}/devel/g" /etc/apt/sources.list && \
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
   unzip\
   vifm \
   gtkwave \
   python3-venv \
   software-properties-common \
   dotnet-sdk-8.0 \
   golang \
   nodejs \
   npm \
   cmake \
   gcc-arm-none-eabi \
   python3-pynvim \
   ripgrep \
   fd-find 
ARG uname
ARG uid
ARG gid
ARG docker_guid
ARG git_user
ARG git_email
COPY ./scripts /opt/scripts
RUN locale-gen en_US.UTF-8
RUN userdel ubuntu
RUN addgroup --gid $gid $uname && addgroup --gid $docker_guid docker
RUN adduser --gecos "" --home /home/$uname --shell /bin/zsh --uid $uid --gid $gid $uname && adduser \
$uname sudo && adduser $uname docker && passwd -d $uname && chown -R $uname:$uname /home/$uname && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> \
/etc/sudoers
RUN git config --global user.name $git_user && git config --global user.email $git_email
ENV PATH="/home/${uname}/.local/share/nvim/mason/bin:${PATH}"
ENV PATH="$PATH:/opt/win_executables:/opt/windows"
USER $uname
RUN bash /opt/scripts/setup.sh $uname
WORKDIR /home/$uname
ENTRYPOINT ["/bin/zsh"]