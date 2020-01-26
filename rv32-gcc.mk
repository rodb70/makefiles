#-----------------------------------------------------------------------------
# Makefile bits for the 32-bit RISCV chip using gcc as the compiler
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
CROSS_COMPILE := /opt/riscv/bin/riscv32-unknown-elf-
endif
# Target suffix set here if not already set
ifeq ($(TARGET_SUFFIX),)
TARGET_SUFFIX := .bin
endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),upper)
include $(MAK_PATH)/$(call GET_COMPILER).mk 

CFLAGS += $(if $(BLD_OPTOMISE),-O$(BLD_OPTOMISE),-Os)

AFLAGS += -march=$(RV32_ARCH)
AFLAGS += -mabi=ilp32
AFLAGS += -msmall-data-limit=8

COMFLAGS += -march=$(RV32_ARCH)
COMFLAGS += -mabi=ilp32
COMFLAGS += -msmall-data-limit=8
COMFLAGS += -nostartfiles -nodefaultlibs -nostdlib 
COMFLAGS += -Wno-strict-prototypes

LFLAGS += -march=$(RV32_ARCH)
LFLAGS += -mabi=ilp32
LFLAGS += -msmall-data-limit=8
LFLAGS += -nodefaultlibs -nostdlib 

ifeq ($(filter specs,$(LFLAGS)),)
LFLAGS += --specs=nano.specs
endif

ODFLAGS += -hw -S

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

# If not linker script error
ifeq ($(LNK_SCR),)
# Error here if linker script not set
$(error No link script for cpu=$(CPU))
endif

LFLAGS += -T$(LNK_SCR) -nostartfiles 

include $(MAK_PATH)/$(call GET_COMPILER).mk 

endif
