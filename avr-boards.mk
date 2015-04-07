#-----------------------------------------------------------------------------
# AVR board defination file for boards using the AVR as the main processor
# 
# This file will define crustal frequency and CPU type.  To be used in 
# avr-<compiler>.mk to set up the correct CPU defines.
#
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

ifeq ($(INC_PART),upper)
ifeq ($(BOARD),mt-db-u4)
AVR_CHIP := atmega32u4
CRYSTAL_FREQ := 16000000UL
LOAD_PROG := avr109
LOAD_PORT := /dev/ttyACM0
else # mt-db-u4
ifeq ($(BOARD),micropendous3)
AVR_CHIP := $(if $(AVR_CHIP),$(AVR_CHIP),at90usb646$(info Defaulting to at90usb646))
CRYSTAL_FREQ    := 16000000UL
else # micropendous3
ifeq ($(BOARD),micropendous2)
AVR_CHIP := atmega32u2
CRYSTAL_FREQ    := 8000000UL
else # micropendous2
ifeq ($(BOARD),diecimila)
# Select processor type
AVR_CHIP := atmega168 
CRYSTAL_FREQ    := 16000000UL
else # diecimila
ifeq ($(BOARD),nano_v3)
# Select processor type
AVR_CHIP := atmega328 
CRYSTAL_FREQ    := 16000000UL
else # nano_v3
ifeq ($(BOARD),uno_r3)
AVR_CHIP := atmega328
CRYSTAL_FREQ := 16000000UL
LOAD_PORT := /dev/ttyACM0
LOAD_BAUD := 115200
else # uno-r3
# Add other BOARD types here
$(info BOARD not set trying AVR_CHIP and CRYSTAL_FREQ)
endif # uno-r3
endif # nano_v3
endif # diecimila
endif # micropendous2
endif # micropendous3
endif # mt-db-u4
endif # upper section
