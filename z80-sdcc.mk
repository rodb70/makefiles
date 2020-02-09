#-----------------------------------------------------------------------------
# Makefile target or compiler specific stuff only
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
ifeq ($(INC_PART),upper)
# Before target defines
include $(MAK_PATH)/$(COMPILER).mk 

ifneq ($(SDCC_NO_CODE_SIZE),y)
ifeq ($(FLASH_CODE_SIZE),)
FLASH_CODE_SIZE := 32768
endif
endif

CFLAGS += -mz80

LFLAGS += -mz80
LFLAGS += --code-loc $(if $(CODE_LOC),$(CODE_LOC),0)
LFLAGS += --data-loc $(if $(DATA_LOC),$(DATA_LOC),0x8000)

# end of upper
endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),middle)
# After generic targets 
include $(MAK_PATH)/$(COMPILER).mk 

LOAD_PORT := /dev/ttyUSB0
#LOAD_PARMS := -o bridge
#LOAD_PARMS += -p $(LOAD_PORT)
#LOAD_PROG := lpc935-prog

# Target to program the LPC935 using my programming tool
#load: $(BLD_OUTPUT)/$(BLD_TARGET)$(TARGET_SUFFIX)
#	$(LOAD_PROG) $(LOAD_PARMS) -w p2icp 1
#	@echo "Erasing 0 - 0x13ff" $(NOOUT)
#	$(LOAD_PROG) $(LOAD_PARMS) -e sector -a 0
#	$(LOAD_PROG) $(LOAD_PARMS) -e sector -a 0x400
#	$(LOAD_PROG) $(LOAD_PARMS) -e sector -a 0x800
#	$(LOAD_PROG) $(LOAD_PARMS) -e sector -a 0xc00
#	$(LOAD_PROG) $(LOAD_PARMS) -e sector -a 0x1000
#	$(LOAD_PROG) $(LOAD_PARMS) -g $<
#	$(LOAD_PROG) $(LOAD_PARMS) -s

# end of middle
endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),lower)

# Bottom of the make file stuff
include $(MAK_PATH)/$(COMPILER).mk 

#end of lower
endif

