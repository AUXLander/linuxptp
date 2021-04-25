ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

incdefs := $(shell $(ROOT_DIR)/incdefs.sh)

LIB_NAME = libdistribution.so
LIB_SUBDIR = /randvardistribution/src/
LIB_PATH = $(ROOT_DIR)$(LIB_SUBDIR)$(LIB_NAME)

LIB_INSTALL_PATH = /usr/lib/

CC = $(CROSS_COMPILE)gcc
CFLAGS = -O3 $(incdefs)
LDLIBS = -lm -lrt -pthread $(EXTRA_LDFLAGS)
PRG	= ptp4l

FILTERS	= filter.o mave.o mmedian.o kalman.o
SERVOS	= linreg.o ntpshm.o nullf.o pi.o servo.o
TRANSP	= raw.o transport.o udp.o udp6.o uds.o

OBJ	= bmc.o clock.o clockadj.o clockcheck.o config.o \
 e2e_tc.o fault.o $(FILTERS) fsm.o hash.o msg.o phc.o \
 port.o port_signaling.o pqueue.o print.o p2p_tc.o rtnl.o $(SERVOS) \
 sk.o stats.o tc.o $(TRANSP) telecom.o tlv.o tsproc.o unicast_client.o \
 unicast_fsm.o unicast_service.o util.o version.o 

SRC	= $(OBJECTS:.o=.c)
DEPEND	= $(OBJECTS:.o=.d)

all: ptp4l 

ptp4l: ptp4l.o $(OBJ) 
	gcc $(OBJ) $(LDLIBS) -o ptp4l ptp4l.o

clean:
	rm -f $(OBJ) $(DEPEND) $(PRG) *.o *.d *.d.*

master:
	sudo ./ptp4l -4 -H -P -i enp0s8 -m

slave:
	sudo ./ptp4l -4 -H -P -i enp0s8 -m -s

testdef:
	echo $(incdefs)

# Implicit rule to generate a C source file's dependencies.
%.d: %.c
	@echo DEPEND $<; \
	rm -f $@; \
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< > $@.$$$$;