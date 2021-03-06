FROM nvcr.io/nvidia/tensorflow:19.10-py3
LABEL yasuhiro osaka (md20017@shibaura-it.ac.jp)

SHELL ["/bin/bash", "-c"]
Arg UNAME=ubuntu
Arg UID=1000
Arg arglist="UNAME UID"

ENV DEBIAN_FRONTEND "noninteractive"
RUN apt-get update 
#&& apt-get install -y openssh-server
RUN apt-get install -y cmake libopenmpi-dev zlib1g-dev python3-tk
RUN apt install -y emacs screen htop
# RUN mkdir /var/run/sshd
# RUN echo 'root:root' | chpasswd
# RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
# RUN sed -i.bak -e "s%http://archive.ubuntu.com/ubuntu/%http://ftp.iij.ad.jp/pub/linux/ubuntu/archive/%g" /etc/apt/sources.list
RUN apt-get update && apt-get upgrade -y
RUN apt-get install sudo

## installing vscode
RUN apt install -y curl
# RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
# RUN install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
# RUN sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
# RUN apt install apt-transport-https
# RUN apt update && apt install -y code


RUN pip install --upgrade pip
RUN pip install gym
###### Stable-baselines
RUN pip install stable-baselines[mpi]
###### other library
RUN pip install seaborn tqdm pydot torch torchvision

##  Create User
RUN useradd -m --uid ${UID} -d /home/${UNAME} --groups sudo  ${UNAME}
RUN echo "${UNAME}:ubuntu" | chpasswd
RUN echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chown -R ${UNAME}:${UNAME} /home/${UNAME}
RUN usermod -aG sudo $UNAME
RUN chsh -s /bin/bash ${UNAME}
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN apt-get autoclean
USER ${UNAME}
WORKDIR /home/${UNAME}
ENV HOME /home/${UNAME}
################################################################################
##  Bash setting
RUN echo 'export PATH=/usr/local/cuda/bin:$PATH' >> /home/$UNAME/.bashrc
RUN echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> /home/$UNAME/.bashrc
RUN echo 'export CPATH=$HOME/cuda/include:$CPATH' >> /home/$UNAME/.bashrc
RUN echo 'export LIBRARY_PATH=$HOME/cuda/lib64:$LIBRARY_PATH' >> /home/$UNAME/.bashrc
RUN echo 'export LD_LIBRARY_PATH=$HOME/cuda/lib64:$LD_LIBRARY_PATH' >> /home/$UNAME/.bashrc


RUN echo 'PS1_COLOR_BEGIN="\[\e[1;31m\]"' >> /home/$UNAME/.bashrc
RUN echo 'PS1_COLOR_END="\[\e[m\]"' >> /home/$UNAME/.bashrc
RUN echo 'PS1_HOST_NAME="docker"' >> /home/$UNAME/.bashrc
RUN echo 'export PS1="${PS1_COLOR_BEGIN}\u@\${PS1_HOST_NAME} \W${PS1_COLOR_END}\\$ "' >> /home/$UNAME/.bashrc

## install codeserver
RUN curl -fsSL https://code-server.dev/install.sh | sh
#RUN mkdir -p $HOME/.local/lib $HOME/.local/bin
#RUN curl -fL https://github.com/cdr/code-server/releases/download/v3.4.1/code-server-3.4.1-linux-amd64.tar.gz | tar -C $HOME/.local/lib -xz
#RUN mv $HOME/.local/lib/code-server-3.4.1-linux-amd64 $HOME/.local/lib/code-server-3.4.1
#RUN ln -s $HOME/.local/lib/code-server-3.4.1/bin/code-server $HOME/.local/bin/code-server

## install code-server-extensions
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension ms-dotnettools.csharp
RUN code-server --install-extension ms-vscode.cpptools

## copy rcfiles
COPY .screenrc /home/$UNAME/
COPY .emacs /home/$UNAME/
COPY .nanorc /home/$UNAME/

# EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
