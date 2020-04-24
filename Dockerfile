# https://veins.car2x.org/tutorial/
# https://omnetpp.org/doc/omnetpp/InstallGuide.pdf
FROM ubuntu:18.04

ENV SUMO_VERSION 0.32.0
ENV OMNET_VERSION 5.6
ENV VEINS_VERSION 5.0

ENV TZ=Europe/Zurich
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

MAINTAINER Andre Pereira andrespp@gmail.com

# Install dependencies #libgdal1-dev
RUN apt-get update && apt-get install -y xauth unzip wget vim \
	build-essential cmake gcc g++ bison flex perl tcl-dev tk-dev blt \
	libxml2-dev zlib1g-dev default-jre doxygen graphviz \
	libwebkitgtk-3.0-0 openmpi-bin libopenmpi-dev libpcap-dev autoconf \
	automake libtool libproj-dev libfox-1.6-dev libgdal-dev \
	libxerces-c-dev qt4-dev-tools python python3 \
	qt5-default libqt5opengl5-dev openscenegraph \
	libopenscenegraph-dev openscenegraph-plugin-osgearth  osgearth \
	osgearth-data libgeos-dev software-properties-common libgl2ps-dev swig && \
	add-apt-repository -y ppa:ubuntugis/ppa && \
	apt-get update && apt-get -y install libosgearth-dev

WORKDIR /root

# Buil and Install SUMO
# http://sumo.dlr.de/wiki/Installing/Linux_Build
RUN wget https://downloads.sourceforge.net/project/sumo/sumo/version%20$SUMO_VERSION/sumo-src-$SUMO_VERSION.tar.gz && \
	tar zxf sumo-src-$SUMO_VERSION.tar.gz && \
	rm sumo-src-$SUMO_VERSION.tar.gz && \
	export SUMO_HOME="/root/sumo-$SUMO_VERSION" && \
	cd sumo-$SUMO_VERSION/ && \
	./configure && \
	make && \
	make install && \
	cd ..

# Build and Install OMNet++ IDE
RUN	wget https://github.com/omnetpp/omnetpp/releases/download/omnetpp-$OMNET_VERSION/omnetpp-$OMNET_VERSION-src-linux.tgz && \
	tar zxvf omnetpp-$OMNET_VERSION-src-linux.tgz && \
	rm omnetpp-$OMNET_VERSION-src-linux.tgz && \
	cd /root/omnetpp-$OMNET_VERSION && \
	export PATH=$PATH:/root/omnetpp-$OMNET_VERSION/bin && \
	./configure && \
	make

# Download and Unzip Veins
RUN cd /root && wget https://veins.car2x.org/download/veins-$VEINS_VERSION.zip && \
	unzip veins-$VEINS_VERSION.zip && \
	rm veins-$VEINS_VERSION.zip

COPY ./entrypoint.sh /

RUN mkdir -p /root/omnet-samples && \
	cp -R /root/omnetpp-$OMNET_VERSION/samples/* /root/omnet-samples

ENV SUMO_HOME /root/sumo-$SUMO_VERSION

# Install Python PIP and dependencies
RUN	apt-get update && apt-get -y upgrade && \
	apt-get install -y python-pip python-tk && \
	pip install matplotlib

# Get openflow extension
RUN	wget https://github.com/danhld/openflow/archive/master.zip && \
	unzip master.zip && \
	rm master.zip && \
	mv openflow-master/ openflow-omnetpp5-inet3.x-extension

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
