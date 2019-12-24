#-----------------------------------------------------------------------------
# Makefile bits for the LPC81X chip using gcc as the compiler
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
ifdef ($(CROSS_COMPILE),)
CROSS_COMPILE := arm-none-eabi-
endif
# Target suffix set here if not already set
ifeq ($(TARGET_SUFFIX),)
TARGET_SUFFIX := .bin
endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),upper)
include $(MAK_PATH)/$(call GET_COMPILER).mk 

CFLAGS += $(if $(BLD_OPTOMISE),-O$(BLD_OPTOMISE),-Os)

# ARM7
AFLAGS += -mcpu=arm7tdmi


CFLAGS += -mcpu=arm7tdmi


LFLAGS += -mcpu=arm7tdmi
ifeq ($(filter --specs%,$(LFLAGS)),)
LFLAGS += --specs=nosys.specs
endif

ODFLAGS += -h -S
ifneq ($(BLD_TYPE),lint)
ALL_TARGETS += $(BLD_OUTPUT)/$(BLD_TARGET).lss
endif
endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),middle)
# After generic targets 
include $(MAK_PATH)/$(call GET_COMPILER).mk 

endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),lower)

# If no linker script defined use the default
ifeq ($(LNK_SCR),)
# only set this here if not already set this means this can be overriden
LNK_SCR := source/cpu/lpc2124/lpc2124-rom.ld
endif

LFLAGS += -T$(LNK_SCR) -nostartfiles 

include $(MAK_PATH)/$(call GET_COMPILER).mk 

endif
