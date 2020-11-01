#-----------------------------------------------------------------------------
# Makefile target or compiler specific stuff only
# cc65 compiler tool suit see https://cc65.github.io/
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
#
#-----------------------------------------------------------------------------
ifeq ($(INC_PART),upper)

# Standard to compile source code to
#CSTANDARD := --standard c99

# Compiler  
CC=cc65
AS=ca65
LD=ld65
# Librarian
AR := ar65

CFLAGS += -g

ifeq ($(BLD_TYPE),debug)
#CFLAGS += --debug --debug-info
#LFLAGS += --debug --debug-info
#ADEBUG += -y
endif

LIB_PREFIX :=
LIB_SUFFIX := .lib

# Used to only have one library declaration
LIBRARY_LIST :=
# Macro to generate library build rules
define GEN_LIBS
ifeq ($(findstring $(1),$(LIBRARY_LIST)),)
LIBRARY_LIST += $(1)
$(1)-deps :=
$(1)-deps += $$(addprefix $$(BLD_OUTPUT)/,$$(patsubst %.s,%.o,$$(filter %.s,$$(SRC-$(1)))))
$(1)-deps += $$(addprefix $$(BLD_OUTPUT)/,$$(patsubst %.c,%.o,$$(filter %.c,$$(SRC-$(1)))))
$(BLD_OUTPUT)/$(LIB_PREFIX)$(1)$(LIB_SUFFIX): $$($(1)-deps)
    @echo "Library   : $$(notdir $$@)" $(NOOUT)
    $(AR) -r $$@ $$^

endif
endef
# end of upper
endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),middle)

# end of middle
endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),lower)
# Apply the compilation standard
CFLAGS += $(CSTANDARD)
# Common flags
CFLAGS += $(COMFLAGS)
CPPFLAGS += $(COMFLAGS)

$(foreach lib,$(LIB-app),$(eval $(call GEN_LIBS,$(lib))))

$(BLD_OUTPUT)/%.o: %.c $(sort $(MAKEFILE_LIST)) $(PRE_TARGETS)
	@echo "Compiling : $(notdir $<)" $(NOOUT)
	$(call IF_NOT_EXIST_MKDIR,$(@D))
	$(CC) --create-full-dep $(basename $@).d $(CFLAGS) $(CFLAGS-$(<F)) $< -o $(basename $@).s
	$(AS) $(basename $@).s -o $@

$(BLD_TARGET)-bldeps :=
$(BLD_TARGET)-bldeps += $(addprefix $(BLD_OUTPUT)/,$(patsubst %.c,%.o,$(filter %.c,$(SRC_MAIN))))
$(BLD_TARGET)-bldeps += $(addprefix $(BLD_OUTPUT)/,$(patsubst %.s,%.o, $(filter %.s,$(SRC-app))))
$(BLD_TARGET)-bldeps += $(addprefix $(BLD_OUTPUT)/,$(patsubst %.c,%.o, $(filter %.c,$(SRC-app))))
$(BLD_TARGET)-bldeps += $(addprefix $(BLD_OUTPUT)/,$(filter %$(LIB_SUFFIX),$(SRC-app)))

$(BLD_OUTPUT)/$(BLD_TARGET): $($(BLD_TARGET)-bldeps)
	@echo "Linking   : $(notdir $@)" $(NOOUT)
	$(LD) -o $@ $(LFLAGS) $^ $(EXTRA_LIBS)

#end of lower
endif
