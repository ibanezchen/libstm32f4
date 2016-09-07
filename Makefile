PREFIX ?= $(shell pwd)/../prefix/$(CROSS:%-=%)
SOC?=linkit
NAME   :=stm32f4xx
TARGET :=arm-none-eabi
CROSS  :=$(TARGET)-
CPU    :=arm
INCLUDE:=-Iinclude -I$(PREFIX)/include $(SOC_INC) \
	-I$(PREFIX)/include/aws-iot
COPTS  ?=-march=armv7-m -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard -fsingle-precision-constant -Wdouble-promotion

AARCH  :=$(shell echo $(COPTS) | sed -e 's/.*armv\([0-9]\).*/\1/g')
MOPTS  :=$(COPTS) \
	-DCFG_AARCH=$(AARCH) \
	-fno-builtin -fno-common \
	-ffunction-sections -fdata-sections -fshort-enums
CONFIG = -DUSE_STDPERIPH_DRIVER -DSTM32F40_41xxx
ASFLAGS:=$(MOPTS) $(CONFIG) -O2 -g -Wall -Werror -D __ASSEMBLY__
CFLAGS :=$(MOPTS) $(CONFIG) -O2 -g -Wall -Werror
LSCRIPT?=rom.ld
LDFLAGS:=

MSCRIPT:=$(PREFIX)/share/mod.ld
LIB    :=lib$(NAME).a

ALL    :=gen stm32f4xx_conf.h lib
CLEAN  :=
CPU    :=arm

VPATH  :=src
VOBJ   :=$(patsubst %.S,%.o, \
		$(patsubst %.c,%.o, \
		$(patsubst %.cpp, %.o, \
			$(notdir $(foreach DIR,$(VPATH),\
				$(wildcard $(DIR)/*.S)	\
				$(wildcard $(DIR)/*.c) 	\
				$(wildcard $(DIR)/*.cpp))))))
default:all

include $(PREFIX)/share/Makefile.rule

gen:
	rm -f src/* include/*
	cp `find $(STLIB)/Libraries/CMSIS/ -name "*.h" | sed -e '/Example/d' | sed -e '/Template/d'` include
	cp $(STLIB)/Libraries/STM32F4xx_StdPeriph_Driver/src/* src/
	cp $(STLIB)/Libraries/STM32F4xx_StdPeriph_Driver/inc/* include/
	rm -f src/stm32f4xx_fmc.c
	cp stm32f4xx_conf.h include/stm32f4xx_conf.h
	
	
