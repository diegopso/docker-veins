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
	mv openflow-master/ openflow && \
	sed -i "s/class inet::PingPayload\;/namespace inet \{class PingPayload\;\}/g" /root/openflow/apps/PingAppRandom.h

# Get INET 3.5.0 and setup for openflow extension
RUN	wget https://github.com/inet-framework/inet/archive/v3.99.3.zip && \
	unzip v3.99.3.zip && \
	rm v3.99.3.zip && \
	wget https://raw.githubusercontent.com/inet-framework/inet/fccb335dfcb01e2890e4b39a8d65610f4010d6e9/src/inet/visualizer/scene/SceneOsgEarthVisualizer.h && \
	wget https://raw.githubusercontent.com/inet-framework/inet/fccb335dfcb01e2890e4b39a8d65610f4010d6e9/src/inet/common/geometry/common/GeographicCoordinateSystem.cc && \
	wget https://raw.githubusercontent.com/inet-framework/inet/fccb335dfcb01e2890e4b39a8d65610f4010d6e9/src/inet/common/geometry/common/GeographicCoordinateSystem.ned && \
	wget https://raw.githubusercontent.com/inet-framework/inet/fccb335dfcb01e2890e4b39a8d65610f4010d6e9/src/inet/visualizer/scene/SceneOsgEarthVisualizer.cc && \
	mv GeographicCoordinateSystem.* /root/inet-3.99.3/src/inet/common/geometry/common/ && \
	mv SceneOsgEarthVisualizer.* /root/inet-3.99.3/src/inet/visualizer/scene/ && \
	sed -i "s/cPacketQueue(name, nullptr)/cPacketQueue(name, (Comparator *) nullptr)/g" inet-3.99.3/src/inet/common/queue/PacketQueue.cc && \
	sed -i "s/cQueue(name, nullptr)/cQueue(name, (Comparator *) nullptr)/g" inet-3.99.3/src/inet/linklayer/ieee80211/mac/queue/Ieee80211Queue.cc && \
	sed -i '0,/if (ift)/ s/if (ift)/if (ift \&\& par("doRegisterAtIft").boolValue())/g' /root/inet-3.99.3/src/inet/linklayer/base/MacBase.cc && \
	sed -i "0,/parameters:/ s/parameters:/parameters:\n        bool doRegisterAtIft = default(true); \/\/ openflow compatibility/g" /root/inet-3.99.3/src/inet/linklayer/ethernet/EtherMac.ned && \
	sed -i "0,/parameters:/ s/parameters:/parameters:\n        bool doRegisterAtIft = default(true); \/\/ openflow compatibility/g" /root/inet-3.99.3/src/inet/linklayer/ethernet/EtherMacFullDuplex.ned

# Install valgrind for profiling
RUN	apt-get install -y apt-utils && \
	apt-get install -y valgrind

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
