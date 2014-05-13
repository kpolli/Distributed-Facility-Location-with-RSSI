#!/bin/bash
# Compile snippet to compile for mica2 motes
# $1 -> Mote ID
# $2 -> USB Device
# $3 -> Baud rate for the device

make micaz install.$1 mib520,/dev/ttyUSB$2

# If you are using printf uncomment the next line.
# First make sure you have the changed the baudrate under /opt/tinyos/tos/platforms/<platform-name>/hardware.h
# Secondly, add `CFLAGS += -DPRINTF_BUFFER_SIZE=512` and `CFLAGS += -I$(TOSDIR)/lib/printf` in your Makefile.

# java net.tinyos.tools.PrintfClient -comm serial@/dev/ttyUSB1$2:$3

