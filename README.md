docker-veins
============

Docker image for [Veins Simulator](https://veins.car2x.org/)

## Introduction

Veins is an open source framework for running vehicular network simulations.

It is based on two well-established simulators: [OMNeT++](https://www.omnetpp.org/), an event-based network simulator, and [SUMO](http://sumo.dlr.de/index.html), a road traffic simulator.

It extends these to offer a comprehensive suite of models for IVC simulation.

## Usage

### Clone the repository

```console
$ git clone https://github.com/diegopso/docker-veins.git
```

### Build Docker Image

```console
$ make setup
```

### Run

```console
$ make run-bash
$ /entrypoint.sh omnet
```

### Import Omnet++ Samples

The samples are copied to `/root/omnet-samples`, if you want to import it look for this directory.

### Import and Build Veins Project

Copy 	the framework in the samples directory to prevent data loss.

```
cp -R /root/veins-veins-5.0 /root/omnetpp-5.6/samples/veins
```

Import the project into your OMNeT++ IDE workspace by clicking `File > Import > General: Existing Projects into Workspace` and selecting the directory `/root/omnetpp-5.6/samples/veins-veins-5.0`.

Build the newly imported project by choosing `Project > Build All` in the OMNeT++ 5 IDE.

After the project built, you are ready to run your first IVC evaluations, but to ease debugging, the next step will ensure that SUMO works as it should.

### Import and Build Inet and Openflow Extension

Copy in the samples directory to prevent data loss.

```
cp -R /root/openflow /root/omnetpp-5.6/samples/
cp -R /root/inet-3.99.3 /root/omnetpp-5.6/samples/
```

Import the project into your OMNeT++ IDE workspace by clicking `File > Import > General: Existing Projects into Workspace` and selecting the directories `/root/omnetpp-5.6/samples/openflow-omnetpp5-inet3.x-extension` and `/root/omnetpp-5.6/samples/inet-3.5.0`.

Build the newly imported project by choosing `Project > Build All` in the OMNeT++ 5 IDE.

### Make sure SUMO is working

```console
sumo-gui /root/veins-veins-5.0/examples/veins/erlangen.sumo.cfg
```

### Run the Veins demo scenario

To save you the trouble of manually running SUMO prior to every OMNeT++ simulation, the Veins module framework comes with a small python script to do that for you. In the OMNeT++ MinGW command line window, run:

```console
/root/veins-veins-5.0/sumo-launchd.py -vv -c sumo
```

In the OMNeT++ 5 IDE, simulate the Veins demo scenario by right-clicking on `veins-5.0/examples/veins/omnetpp.ini` and choosing `Run As > OMNeT++ simulation`.

Similar to the last example, this should create and start a launch configuration. You can later re-launch this configuration by clicking the green Run button in the OMNeT++ 5 IDE.

## Requirements

* Docker
* X11 with xauth

## References
* [Veins Instalation Tutorial](https://veins.car2x.org/tutorial/)
