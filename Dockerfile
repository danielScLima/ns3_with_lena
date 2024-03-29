FROM ubuntu:22.04
#FROM ubuntu:20.04

LABEL "inetsys.team" = "ns3_3.40.1 image" \
    version = "1.0" \
    description = "Base docker image of ns3 3.40.1 with Ubuntu 22.04 LTS" \
    author = "daniellima32@gmail.com"

ARG DEBIAN_FRONTEND noninteractive

RUN apt update

RUN DEBIAN_FRONTEND=noninteractive TZ=America/Fortaleza apt install -y build-essential autoconf automake

RUN DEBIAN_FRONTEND=noninteractive TZ=America/Fortaleza apt install -y gcc g++ cmake ninja-build git vim mercurial

RUN DEBIAN_FRONTEND=noninteractive TZ=America/Fortaleza apt install -y python3 python3-dev python-setuptools python3-pip

RUN DEBIAN_FRONTEND=noninteractive TZ=America/Fortaleza apt install -y libc6-dev sqlite sqlite3 libsqlite3-dev

RUN DEBIAN_FRONTEND=noninteractive TZ=America/Fortaleza apt install -y unrar tcpdump wget

RUN DEBIAN_FRONTEND=noninteractive TZ=America/Fortaleza apt install -y libxml2 libc6-dev libicu-dev

RUN DEBIAN_FRONTEND=noninteractive TZ=America/Fortaleza apt install -y libxml2 libxml2-dev libboost-all-dev

RUN DEBIAN_FRONTEND=noninteractive TZ=America/Fortaleza apt install -y openmpi-bin openmpi-common openmpi-doc libopenmpi-dev

# RUN DEBIAN_FRONTEND=noninteractive TZ=America/Fortaleza apt install -y bzr

RUN pip install -v cppyy

RUN apt update

RUN apt install -y libeigen3-dev
RUN apt install -y libgsl-dev

#Aprox 300 MB
RUN apt install -y libgtk-3-dev

# create inetsys user
RUN groupadd -r inetsys && useradd -m -d /home/inetsys -g inetsys inetsys

RUN echo "inetsys:inetsys" | chpasswd

#RUN mkdir -p /usr/ns3
WORKDIR /home/inetsys/ns3_env

# Clonar o brite
# Modules that cannot be built:
# brite                     click                     mpi                       
# nr-u                      openflow                  visualizer 

# Modules that cannot be built:
# mpi                       nr-u                      visualizer 

# Modules that cannot be built:
# nr-u                      visualizer 

# Configurar o brite
RUN hg clone http://code.nsnam.org/BRITE && cd BRITE && make

# Configurar o openflow
RUN hg clone http://code.nsnam.org/openflow && cd openflow && ./waf configure && ./waf build

# Configurar click
RUN git clone https://github.com/kohler/click && cd click/ && ./configure --disable-linuxmodule --enable-nsclick --enable-wifi && make

RUN git clone https://gitlab.com/nsnam/ns-3-dev.git

# Altero o branch do ns3
RUN cd ns-3-dev && git checkout ns-3.40

# Clonar o repositório do NR
RUN cd ns-3-dev/contrib && git clone https://gitlab.com/cttc-lena/nr.git

RUN cd ns-3-dev/contrib/nr && git checkout 5g-lena-v2.6.y

# Clonar o repositório do NR-U

RUN cd ns-3-dev/contrib && git clone https://gitlab.com/cttc-lena/nr-u.git

# netmap
# no docker não está instável
# RUN git clone https://github.com/luigirizzo/netmap
# RUN cd netmap && ./configure --kernel-sources=/usr/src/linux-headers-5.15.0-91-generic && make && make install


# Fazendo configure

# build-profile: debug ou optimized
# RUN cd ns-3-dev/ && ./ns3 configure --build-profile=debug --enable-examples --enable-tests 
RUN cd ns-3-dev/ && ./ns3 configure --enable-python-bindings --enable-mpi --with-click=/home/inetsys/ns3_env/click --with-brite=/home/inetsys/ns3_env/BRITE --with-openflow=/home/inetsys/ns3_env/openflow --build-profile=debug --enable-examples --enable-tests 

RUN cd ns-3-dev/ && ./ns3 build

RUN apt clean && rm -rf /var/lib/apt/lists/* 

# CMD tail -f /dev/null