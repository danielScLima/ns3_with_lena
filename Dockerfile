FROM ubuntu:22.04
LABEL "inetsys.team" = "ns3_3.40.1 image" \
    version = "1.0" \
    description = "Base docker image of ns3 3.40.1 with Ubuntu 22.04 LTS" \
    author = "daniellima32@gmail.com"

ARG DEBIAN_FRONTEND noninteractive

RUN apt update

RUN DEBIAN_FRONTEND=noninteractive TZ=America/Fortaleza apt install -y build-essential autoconf automake

RUN DEBIAN_FRONTEND=noninteractive TZ=America/Fortaleza apt install -y gcc g++ cmake ninja-build git vim mercurial

RUN DEBIAN_FRONTEND=noninteractive TZ=America/Fortaleza apt install -y python3 python-setuptools python3-pip

RUN DEBIAN_FRONTEND=noninteractive TZ=America/Fortaleza apt install -y libc6-dev sqlite sqlite3 libsqlite3-dev

RUN DEBIAN_FRONTEND=noninteractive TZ=America/Fortaleza apt install -y unrar tcpdump wget

# create inetsys user
RUN groupadd -r inetsys && useradd -m -d /home/inetsys -g inetsys inetsys

RUN echo "inetsys:inetsys" | chpasswd

#RUN mkdir -p /usr/ns3
WORKDIR /home/inetsys/ns3_env

# Clonar o brite
# Modules that cannot be built:
# brite                     click                     mpi                       
# nr-u                      openflow                  visualizer 

# Configurar o brite
RUN hg clone http://code.nsnam.org/BRITE && cd BRITE && make

RUN git clone https://gitlab.com/nsnam/ns-3-dev.git

# Altero o branch do ns3
RUN cd ns-3-dev && git checkout ns-3.40

# Clonar o repositório do NR
RUN cd ns-3-dev/contrib && git clone https://gitlab.com/cttc-lena/nr.git

RUN cd ns-3-dev/contrib/nr && git checkout 5g-lena-v2.6.y

# Clonar o repositório do NR-U

RUN cd ns-3-dev/contrib && git clone https://gitlab.com/cttc-lena/nr-u.git

# Fazendo configure

RUN cd ns-3-dev/ && ./ns3 configure --with-brite=/home/inetsys/ns3_env/BRITE --build-profile=debug --enable-examples --enable-tests 

RUN cd ns-3-dev/ && ./ns3 build

RUN apt clean && rm -rf /var/lib/apt/lists/* 

# CMD tail -f /dev/null