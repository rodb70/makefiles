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
# Detect either fedora or ubuntu
__sdccSysType := $(shell cat /etc/issue | grep -i fedora)
ifneq ($(__sdccSysType),)
__sdccCross := sdcc-
endif

# Locate a dos2unix tool there are 2 possibilities that can operate in a similar way
UNIX2DOS := $(firstword $(wildcard $(addsuffix /unix2dos,$(subst :, ,$(PATH)))))
ifeq ($(UNIX2DOS),)
UNIX2DOS := $(wildcard $(addsuffix /todos,$(subst :, ,$(PATH))))
endif

# Standard to compile source code to
CSTANDARD := --std-sdcc99

# Compiler	
CC := $(__sdccCross)sdcc
CPP := $(__sdccCross)sdcpp
# AS assemblers
AS8051 := $(__sdccCross)asx8051
ASGB80 := $(__sdccCross)as-gbz80
ASZ80  := $(__sdccCross)sdasz80
# Librarian
AR := $(__sdccCross)sdcclib
# makebin
MKBIN := $(__sdccCross)makebin
# packhex command
PKHX := $(__sdccCSross)packihx

ifneq ($(filter -mmcs51,$(CFLAGS)),)
# Sort out BLD_MODEL
ifeq ($(call TOLOWERCASE,$(BLD_MODEL)),large)
TARGET_MODEL := --model-large
else
ifeq ($(call TOLOWERCASE,$(BLD_MODEL)),medium)
TARGET_MODEL := --model-medium
else
# default to small model 
TARGET_MODEL := --model-small
endif
endif
ifeq ($(TARGET_MODEL),)
$(error BLD_MODEL not set correctly should be small, medium or large) 
endif
endif
# Target suffix
TARGET_SUFFIX := $(if $(TARGET_SUFFIX),$(TARGET_SUFFIX),.hex)

ifeq ($(BLD_TYPE),debug)
CFLAGS += --debug
LFLAGS += --debug
ADEBUG += -y
endif
CFLAGS += --Werror

LIB_PREFIX :=
LIB_SUFFIX := .lib

# Used to only have one library declaration
LIBRARY_LIST :=
# Macro to generate library build rules
define GEN_LIBS
ifeq ($(findstring $(1),$(LIBRARY_LIST)),)
LIBRARY_LIST += $(1)
$(1)-deps :=
$(1)-deps += $$(addprefix $$(BLD_OUTPUT)/,$$(patsubst %.asm,%.rel,$$(filter %.asm,$$(SRC-$(1)))))
$(1)-deps += $$(addprefix $$(BLD_OUTPUT)/,$$(patsubst %.c,%.rel,$$(filter %.c,$$(SRC-$(1)))))
$(BLD_OUTPUT)/$(LIB_PREFIX)$(1)$(LIB_SUFFIX): $$($(1)-deps)
	@echo "Library   : $$(notdir $$@)" $(NOOUT)
	$(AR) -r $$@ $$^
endif
endef
# end of upper
endif
#-----------------------------------------------------------------------------
ifeq ($(INC_PART),middle)
# After generic targets 
ifneq ($(SDCC_NO_CODE_SIZE),y)
LFLAGS += --code-size $(FLASH_CODE_SIZE)
endif

# end of middle
endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),lower)
# Apply the compilation standard
CFLAGS += $(CSTANDARD)
# Common flags
CFLAGS += $(COMFLAGS)
CPPFLAGS += $(COMFLAGS)
ifeq ($(SRC_MAIN),)
$(if $(filter -mmcs51,$(CFLAGS)),$(error SRC_MAIN not defined you must declare this to compile with SDCC))
endif
# Search and locate SDCC_MAIN file in the include list
__sdccMainFile := $(if $(filter -mmcs51,$(CFLAGS)),$(wildcard $(if $(INC),$(addsuffix /$(SRC_MAIN),$(INC)),$(SRC_MAIN))))
$(if $(word 2,$(__sdccMainFile)),$(error SRC_MAIN declared more than once))
$(if $(filter -mmcs51,$(CFLAGS)),$(if $(__sdccMainFile),,$(error Could not find $(SRC_MAIN))))
SRC_MAIN := $(__sdccMainFile)

$(BLD_OUTPUT)/$(TARGET)$(TARGET_SUFFIX): $(BLD_OUTPUT)/$(BLD_TARGET).ihx

$(foreach lib,$(LIB-app),$(eval $(call GEN_LIBS,$(lib))))

$(BLD_OUTPUT)/%.rel: %.c $(sort $(MAKEFILE_LIST)) $(PRE_TARGETS)
	@echo "Compiling : $(notdir $<)" $(NOOUT)
	$(call IF_NOT_EXIST_MKDIR,$(@D))
	$(CC) -M $(CPPFLAGS) $< | sed "s|^\(.*\).rel|$(BLD_OUTPUT)/$(dir $<)\1.rel|" > $(basename $@).d
	$(CC) -c $(CFLAGS) $< -o $@

ifneq ($(filter -mmcs51,$(CFLAGS)),)
# 8051 specific assembler implcidit rule
$(BLD_OUTPUT)/%.rel: %.asm $(sort $(MAKEFILE_LIST)) $(PRE_TARGETS)
	@echo "Assembling: $(notdir $<)" $(NOOUT)
	$(call IF_NOT_EXIST_MKDIR,$(@D))
	cp $< $(dir $@)
	$(AS8051) $(ADEBUG) -plosgff $(dir $@)/$<

endif

ifneq ($(filter -mz80,$(CFLAGS)),)
# Z80 specific assembler implcidit rule
$(BLD_OUTPUT)/%.rel: %.asm $(sort $(MAKEFILE_LIST)) $(PRE_TARGETS)
	@echo "Assembling: $(notdir $<)" $(NOOUT)
	$(call IF_NOT_EXIST_MKDIR,$(@D))
	cp $< $(dir $@)
	$(ASZ80) $(ADEBUG) -plosgffw $(dir $@)/$<

endif

%.hex: %.ihx
	@echo "Making    : $@" $(NOOUT)
	$(PKHX) $^ > $@ 2> /dev/null
	$(UNIX2DOS) $@ 2> /dev/null
	$(if $(filter -mmcs51,$(CFLAGS)),tail -n 5 $(basename $@).mem)

$(BLD_TARGET)-bldeps :=
$(BLD_TARGET)-bldeps += $(addprefix $(BLD_OUTPUT)/,$(patsubst %.c,%.rel,$(filter %.c,$(SRC_MAIN))))
$(BLD_TARGET)-bldeps += $(addprefix $(BLD_OUTPUT)/,$(patsubst %.asm,%.rel, $(filter %.asm,$(SRC-app))))
$(BLD_TARGET)-bldeps += $(addprefix $(BLD_OUTPUT)/,$(patsubst %.c,%.rel, $(filter %.c,$(SRC-app))))
$(BLD_TARGET)-bldeps += $(addprefix $(BLD_OUTPUT)/,$(filter %$(LIB_SUFFIX),$(SRC-app)))

$(BLD_OUTPUT)/$(BLD_TARGET).ihx: $($(BLD_TARGET)-bldeps)
	@echo "Linking   : $(notdir $@)" $(NOOUT)
	$(CC) $(LFLAGS) $^ -o $@

#end of lower
endif
