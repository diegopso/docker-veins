# https://veins.car2x.org/tutorial/
# https://omnetpp.org/doc/omnetpp/InstallGuide.pdf
FROM ubuntu:18.04

ENV TZ=Europe/Zurich
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

MAINTAINER Andre Pereira andrespp@gmail.com

# Install dependencies #libgdal1-dev
RUN apt-get update && apt-get install -y xauth unzip wget vim \
	build-essential gcc g++ bison flex perl tcl-dev tk-dev blt \
	libxml2-dev zlib1g-dev default-jre doxygen graphviz \
	libwebkitgtk-3.0-0 openmpi-bin libopenmpi-dev libpcap-dev autoconf \
	automake libtool libproj-dev libfox-1.6-dev libgdal-dev \
	libxerces-c-dev qt4-dev-tools python python3 \
	qt5-default libqt5opengl5-dev openscenegraph \
	libopenscenegraph-dev openscenegraph-plugin-osgearth  osgearth \
	osgearth-data libgeos-dev software-properties-common && \
	add-apt-repository -y ppa:ubuntugis/ppa && \
	apt-get update && apt-get -y install libosgearth-dev

WORKDIR /root

# Buil and Install SUMO
# http://sumo.dlr.de/wiki/Installing/Linux_Build
RUN wget https://downloads.sourceforge.net/project/sumo/sumo/version%200.32.0/sumo-src-0.32.0.tar.gz && \
	tar zxf sumo-src-0.32.0.tar.gz && \
	export SUMO_HOME="/root/sumo-0.32.0" && \
	cd sumo-0.32.0/ && \
	./configure && \
	make && \
	make install && \
	cd .. && rm -rf sumo*

# Consider using launchpad
#RUN sudo add-apt-repository ppa:sumo/stable && \
#	sudo apt-get update && \
#	apt-get install sumo sumo-tools sumo-doc

# Build and Install OMNet++ IDE
RUN	wget https://github.com/omnetpp/omnetpp/releases/download/omnetpp-5.6/omnetpp-5.6-src-linux.tgz && \
	tar zxvf omnetpp-5.6-src-linux.tgz && \
	rm omnetpp-5.6-src-linux.tgz && \
	cd /root/omnetpp-5.6 && \
	export PATH=$PATH:/root/omnetpp-5.6/bin && \
	./configure && \
	make

# Download and Unzip Veins
RUN cd /root && wget https://veins.car2x.org/download/veins-5.0.zip && \
	unzip veins-5.0.zip && \
	rm veins-5.0.zip

COPY ./entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
