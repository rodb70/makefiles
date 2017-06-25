#-----------------------------------------------------------------------------
# Makefile bits for the AVR micros using gcc as the compiler
#-License----------------------------------------------------------------------
#Copyright (c) 2011, developer@teamboyce.com
#All rights reserved.
#
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice, 
#   this list of conditions and the following disclaimer in the documentation 
#   and/or other materials provided with the distribution.
# * Neither the name of the Team Boyce Limited nor the names of its contributors 
#   may be used to endorse or promote products derived from this software 
#   without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

#-----------------------------------------------------------------------------
# Cross compile prefix for gcc
CROSS_COMPILE := avr-
# Target suffix set here if not already set
ifeq ($(TARGET_SUFFIX),)
TARGET_SUFFIX := .hex
endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),upper)
include $(MAK_PATH)/$(call GET_COMPILER).mk 
# Eeprom section name and flags for objcopy
EEPROM_SECT := .eeprom
EEPFLAGS :=
EEPFLAGS += -j $(EEPROM_SECT)
EEPFLAGS += --no-change-warnings
EEPFLAGS += --change-section-lma $(EEPROM_SECT)=0
EEPFLAGS += -O ihex

# Coff flags for use in AVR studio or VMLab
COFFLAGS :=
#COFFLAGS += --debugging
COFFLAGS += --change-section-address .data-0x800000
COFFLAGS += --change-section-address .bss-0x800000
COFFLAGS += --change-section-address .noinit-0x800000
COFFLAGS += --change-section-address .eeprom-0x810000
ifeq ($(IS_BOOTLOADER),y)
COFFLAGS += --change-section-address .text-$(BOOT_BASE_ADDRESS)
endif
COFFLAGS += -O coff-avr
#COFFLAGS +=

# Common AVR flags
AVRFLAGS := $(AVRFLAGS)
# Include path to the main library
INC += /usr/lib/avr/include


ifeq ($(BLD_TYPE),debug)
AVRFLAGS += -Os
else
AVRFLAGS += -Os
endif

AVRFLAGS += -fpack-struct
AVRFLAGS += -fshort-enums
AVRFLAGS += -funsigned-char
AVRFLAGS += -funsigned-bitfields
AVRFLAGS += -fno-exceptions 
AVRFLAGS += -fno-move-loop-invariants -fno-tree-scev-cprop -fno-inline-small-functions

CXXFLAGS += -Wno-ignored-qualifiers

-include $(MAK_PATH)/$(CPU)-boards.mk
AVR_CHIP := $(strip $(AVR_CHIP))

ifeq ($(AVR_CHIP),atmega8)
AVRFLAGS += -D__AVR_ATmega8__
LOAD_DEV := m8
BOOT_BASE_ADDRESS := 0x1800
endif

ifeq ($(AVR_CHIP),atmega168)
AVRFLAGS += -D__AVR_ATmega168__
LOAD_DEV := m168
BOOT_BASE_ADDRESS := 0x3800
endif

ifeq ($(AVR_CHIP),atmega328)
AVRFLAGS += -D__AVR_ATmega328P__
LOAD_DEV := atmega328p
BOOT_BASE_ADDRESS := 0x7800
endif

ifeq ($(AVR_CHIP),atmega32u2)
AVRFLAGS += -D__AVR_ATmega32U2__
LOAD_DEV := $(AVR_CHIP)
BOOT_BASE_ADDRESS := 0x3000
endif

ifeq ($(AVR_CHIP),at90usb162)
AVRFLAGS += -D__AVR_AT90USB162__
LOAD_DEV := $(AVR_CHIP)
BOOT_BASE_ADDRESS := 0x3000
endif

ifeq ($(AVR_CHIP),atmega32u4)
AVRFLAGS += -D__AVR_ATmega32U4__
LOAD_DEV := m32u4
BOOT_BASE_ADDRESS := 0x7000
endif

ifeq ($(AVR_CHIP),at90usb646)
AVRFLAGS += -D__AVR_AT90USB646__
LOAD_DEV := $(AVR_CHIP)
BOOT_BASE_ADDRESS := 0xF000
endif

ifeq ($(AVR_CHIP),at90usb647)
AVRFLAGS += -D__AVR_AT90USB647__
LOAD_DEV := $(AVR_CHIP)
BOOT_BASE_ADDRESS := 0xF000
endif

ifeq ($(AVR_CHIP),at90usb1286)
AVRFLAGS += -D__AVR_AT90USB1286__
LOAD_DEV := $(AVR_CHIP)
BOOT_BASE_ADDRESS := 0x1E000
endif

ifeq ($(AVR_CHIP),at90usb1287)
AVRFLAGS += -D__AVR_AT90USB1287__
LOAD_DEV := $(AVR_CHIP)
BOOT_BASE_ADDRESS := 0x1E000
endif

ifeq ($(AVR_CHIP),atmega16u4)
AVRFLAGS += -D__AVR_ATmega16U4__
LOAD_DEV := $(AVR_CHIP)
endif

ifeq ($(AVR_CHIP),atmega32u6)
AVRFLAGS += -D__AVR_ATmega32U6__
LOAD_DEV := $(AVR_CHIP)
endif

$(if $(AVR_CHIP),,$(error AVR_CHIP not set))
$(if $(LOAD_DEV),,$(warning LOAD_DEV not set ignoring))
$(if $(CRYSTAL_FREQ),,$(error CRYSTAL_FREQ not set))

AVRFLAGS += -mmcu=$(AVR_CHIP)
AVRFLAGS += -DF_CPU=$(CRYSTAL_FREQ)

SZFLAGS += --format=avr
SZFLAGS += --mcu=$(subst -mmcu=,,$(filter -mmcu=%,$(AVRFLAGS)))
OCFLAGS += -R $(EEPROM_SECT)
ODFLAGS += -h -S
# Add extra targets here
ifneq ($(BLD_TYPE),lint)
ALL_TARGETS += $(BLD_OUTPUT)/$(BLD_TARGET).eep
ALL_TARGETS += $(BLD_OUTPUT)/$(BLD_TARGET).lss
ALL_TARGETS += avr-size
endif
ifeq ($(IS_BOOTLOADER),y)
LFLAGS += -Wl,--relax,--gc-sections -Wl,--section-start=.text=$(BOOT_BASE_ADDRESS)
endif

endif # upper

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),middle)
# After generic targets 
include $(MAK_PATH)/$(call GET_COMPILER).mk 

AFLAGS += $(AVRFLAGS)
CFLAGS += $(AVRFLAGS)
CXXFLAGS += $(AVRFLAGS)
LFLAGS += $(AVRFLAGS)
#/usr/bin/avrdude -pm168 -carduino -P/dev/ttyUSB0 -b19200 -Uflash:w:arduino-servo.hex:a
LOAD_PARAMS :=
LOAD_PROG := $(if $(LOAD_PROG),$(LOAD_PROG),arduino)
LOAD_PARAMS += -p $(LOAD_DEV)
ifeq ($(LOAD_PROG),arduino)
LOAD_PORT := $(if $(LOAD_PORT),$(LOAD_PORT),/dev/ttyUSB0)
LOAD_BAUD := $(if $(LOAD_BAUD),$(LOAD_BAUD),19200)
LOAD_PARAMS += -P $(LOAD_PORT)
LOAD_PARAMS += -b $(LOAD_BAUD)
endif
LOAD_PARAMS += -c $(LOAD_PROG)
AVRDUDE := avrdude

# This will become the top level target to load an AVR currently we only load 
# flash but AVR's have eeprom and program bits as well.
.PHONY: load
load: flash

# Program the AVR flash
.PHONY: flash
flash: $(BLD_OUTPUT)/$(BLD_TARGET)$(TARGET_SUFFIX)
	@echo "Load flash: $(notdir $<)" $(NOOUT)
	$(AVRDUDE) $(LOAD_PARAMS) -Uflash:w:$<:a

# Write out the size of the AVR project after building it
.PHONY: avr-size
avr-size: $(BLD_OUTPUT)/$(BLD_TARGET).elf
	@echo "image size: " $(NOOUT)
	$(SIZE) $(SZFLAGS) $<
endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),lower)
include $(MAK_PATH)/$(call GET_COMPILER).mk 

%.eep: %.elf
	@echo "Make eep  : $@" $(NOOUT)
	$(OBJCPY) $(EEPFLAGS) $< $@

%.cof: %.elf
	@echo "Make coff  : $@" $(NOOUT)
	$(OBJCPY) $(COFFLAGS) $< $@

endif
