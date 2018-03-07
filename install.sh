#!/bin/sh
###############################################################################
# Copyright (c) 2018  Fraunhofer FOKUS
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#		Avdoot Chalke
#		Sascha Hackel
#		Axel Rennoch
###############################################################################

#################
### VARIABLES ###
#################

# Default project directories
PROJECT_DIR=$(pwd)
SUT=CoAP-server.jar
SUT_DIR=$PROJECT_DIR/sut/$SUT

# Default ports directory
PORTS_DIR=$PROJECT_DIR/ports

# Default ports content
IPL4ASP_DIR=$PORTS_DIR/IPL4asp
COMMON_DIR=$PORTS_DIR/COMMON
COMMON_COMPONENTS_DIR=$PORTS_DIR/Common_Components
TCCUSEFULFUNCTIONS_DIR=$PORTS_DIR/TCCUsefulFunctions

# Default protocol directory
PROTOCOLS_DIR=$PROJECT_DIR/protocols

# Default protocols content
COAP_PROTOCOL_DIR=$PROTOCOLS_DIR/CoAP

#############
### LOGIC ###
#############

# Get IPL4asp
if [ -d "$IPL4ASP_DIR" ]; then
	echo $IPL4ASP_DIR " aready exists"
else 
	git clone https://github.com/eclipse/titan.TestPorts.IPL4asp.git $IPL4ASP_DIR
fi

# Get COMMON_DIR
if [ -d "$COMMON_DIR" ]; then
	echo $COMMON_DIR " aready exists"
else 
	git clone https://github.com/eclipse/titan.ProtocolModules.COMMON.git $COMMON_DIR
fi

# Get Common_Components
if [ -d "$COMMON_COMPONENTS_DIR" ]; then
	echo $COMMON_COMPONENTS_DIR " aready exists"
else 
	git clone https://github.com/eclipse/titan.TestPorts.Common_Components.Socket-API.git $COMMON_COMPONENTS_DIR
fi

# Get CoAP protocol
if [ -d "$COAP_PROTOCOL_DIR" ]; then
	echo $COAP_PROTOCOL_DIR " aready exists"
else 
	git clone http://git.eclipse.org/gitroot/titan/titan.ProtocolModules.CoAP.git $COAP_PROTOCOL_DIR
fi

# Get TCCUseful functions
if [ -d "$TCCUSEFULFUNCTIONS_DIR" ]; then
	echo $TCCUSEFULFUNCTIONS_DIR " aready exists"
else 
	git clone https://github.com/eclipse/titan.Libraries.TCCUsefulFunctions.git $TCCUSEFULFUNCTIONS_DIR
fi



# clean the bin folder 
if [ -d "bin" ]; then
  rm ./bin/* 
else
  mkdir bin 
fi

### BEGIN workaround
# This is a workaround as the IPL4asp modules can't find
# the corresponding TCC modules.
# The TCC modules will be linked directly into IPL4asp folder.

cd $IPL4ASP_DIR/src
ln -s $TCCUSEFULFUNCTIONS_DIR/src/TCCConversion_Functions.ttcn
ln -s $TCCUSEFULFUNCTIONS_DIR/src/TCCConversion.cc
ln -s $TCCUSEFULFUNCTIONS_DIR/src/TCCInterface_Functions.ttcn
ln -s $TCCUSEFULFUNCTIONS_DIR/src/TCCInterface_ip.h
ln -s $TCCUSEFULFUNCTIONS_DIR/src/TCCInterface.cc
cd ../../../bin

### END workaround


### BEGIN remove unnecessary files

rm $COAP_PROTOCOL_DIR/src/CoAP_EncDec.cc
rm $COAP_PROTOCOL_DIR/src/CoAP_Types.ttcn

### END remove unnecessary files

ln -s $COMMON_DIR/src/General_Types.ttcn
ln -s $IPL4ASP_DIR/src/IPL4asp_PortType.ttcn
ln -s $IPL4ASP_DIR/src/IPL4asp_PT.cc
ln -s $IPL4ASP_DIR/src/IPL4asp_PT.hh
ln -s $IPL4ASP_DIR/src/IPL4asp_Types.ttcn
ln -s $COMMON_COMPONENTS_DIR/src/Socket_API_Definitions.ttcn
ln -s $COAP_PROTOCOL_DIR/src/negative_testing/CoAP_EncDec.cc
ln -s $COAP_PROTOCOL_DIR/src/negative_testing/CoAP_Types.ttcn
ln -s $PROJECT_DIR/src/CoAP_Functions.ttcn
ln -s $PROJECT_DIR/src/CoAP_Templates.ttcn
ln -s $PROJECT_DIR/src/CoAP_Testcases.ttcn
ln -s $PROJECT_DIR/src/CoAP_Testcase_Functions.ttcn
ln -s $PROJECT_DIR/src/CoAP_TestSystem.ttcn
ln -s $PROJECT_DIR/src/CoAP_Pixits.ttcn
ln -s $PROJECT_DIR/src/CoAP_CustomTypes.ttcn
ln -s $PROJECT_DIR/src/CoAP_Const.ttcn
ln -s $PROJECT_DIR/cfg/CoAP.cfg

# Create a Makefile
ttcn3_makefilegen -f -g -e CoAPTest *.ttcn *.hh *.cc

# Run the local SUT
x-terminal-emulator -e "java -jar $SUT_DIR"

# Compile the project
make compile
make

# Execute the test suite
ttcn3_start CoAPTest CoAP.cfg
