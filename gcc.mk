#-----------------------------------------------------------------------------
# gcc generic makefile stuff
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

AFLAGS += -x assembler-with-cpp 
AFLAGS += -c 

# Add sections around all functions and data objects to create small exe's
COMFLAGS += -ffunction-sections 
COMFLAGS += -fdata-sections 

# Very tight error checking
COMFLAGS += -pedantic 
COMFLAGS += -pedantic-errors 
COMFLAGS += -Werror 
COMFLAGS += -Wall 
COMFLAGS += -Wextra 
COMFLAGS += -fstrict-overflow

COMFLAGS += -Wno-strict-aliasing
CFLAGS += -Wstrict-prototypes
COMFLAGS += -Wundef
COMFLAGS += -Wextra
COMFLAGS += -Wunreachable-code
COMFLAGS += -fstrict-aliasing
COMFLAGS += -funsigned-bitfields
COMFLAGS += -fshort-enums
COMFLAGS += -fno-builtin
COMFLAGS += -fno-common

ifneq ($(SHORT_ENUMS),n)
# Create smallets enum by default unless disabled in system file
COMFLAGS += -fshort-enums
endif

# C standard to compile aganist 
CFLAGS += -std=gnu99
# C++ standard to compile against
CXXFLAGS += -std=gnu++98
#CXXFLAGS += -std=gnu++0x
CXXFLAGS += -Wno-long-long

# Debugging Stuff
AFLAGS += -g3 -ggdb
CFLAGS += -g3 -ggdb
CXXFLAGS += -g3 -ggdb
LFLAGS += -g3 -ggdb

# Tool chain defines
CXX := $(CROSS_COMPILE)g++
CC := $(CROSS_COMPILE)gcc
AR := $(CROSS_COMPILE)ar
AS := $(CROSS_COMPILE)as
LD := $(CROSS_COMPILE)ld
NM := $(CROSS_COMPILE)nm
RANLIB := $(CROSS_COMPILE)ranlib
STRIP := $(CROSS_COMPILE)strip
SIZE := $(CROSS_COMPILE)size
OBJCPY := $(CROSS_COMPILE)objcopy
OBJDMP := $(CROSS_COMPILE)objdump
ADDR2LINE := $(CROSS_COMPILE)addr2line
READELF := $(CROSS_COMPILE)readelf
GPROF := $(CROSS_COMPILE)gprof
GCONV := $(CROSS_COMPILE)gconv

# GCC static library prefix and suffix extensions
LIB_PREFIX := lib
LIB_SUFFIX := .a


# Used to only have one library declaration
LIBRARY_LIST :=
# Macro to generate library build rules 
define GEN_LIBS
ifeq ($(findstring $(1),$(LIBRARY_LIST)),)
LIBRARY_LIST += $(1)
$(1)-deps :=
$(1)-deps += $$(addprefix $$(BLD_OUTPUT)/,$$(patsubst %.S,%.o, $$(filter %.S,$$(SRC-$(1)))))
$(1)-deps += $$(addprefix $$(BLD_OUTPUT)/,$$(patsubst %.c,%.o,$$(filter %.c,$$(SRC-$(1)))))
$(1)-deps += $$(addprefix $$(BLD_OUTPUT)/,$$(patsubst %.cpp,%.o,$$(filter %.cpp,$$(SRC-$(1)))))
$(1)-deps += $$(addprefix $$(BLD_OUTPUT)/,$$(patsubst %.cc,%.o,$$(filter %.cc,$$(SRC-$(1)))))
$(BLD_OUTPUT)/$(LIB_PREFIX)$(1)$(LIB_SUFFIX): $$($(1)-deps)
	@echo "Library   : $$(notdir $$@)" $(NOOUT)
	$(AR) -Dcr $$@ $$^

endif
endef
# End of upper
endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),middle)
# After generic targets 
# Create a library target

# End of middle
endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),lower)
# Bottom of the make file stuff

# Add common flags to the C and CPP flags list
CFLAGS += $(COMFLAGS)
CXXFLAGS += $(COMFLAGS)


$(BLD_OUTPUT)/$(BLD_TARGET)$(TARGET_SUFFIX): $(BLD_OUTPUT)/$(BLD_TARGET).elf

$(foreach lib,$(LIB-app),$(eval $(call GEN_LIBS,$(lib))))

# Dump out disassembly
%.lss: %.elf
	@echo "disassembly: $@" $(NOOUT)
	$(OBJDMP) $(ODFLAGS) $< > $@

# Output an Intel hex file from an elf file
%.hex: %.elf
	@echo "Make hex  : $@" $(NOOUT)
	$(OBJCPY) $(OCFLAGS) -O ihex $< $@

# Output a bin file from an elf file
%.bin: %.elf
	@echo "Make bin  : $@" $(NOOUT)
	$(OBJCPY) $(OCFLAGS) -O binary $< $@

# Build an object fril from a C source file
$(BLD_OUTPUT)/%.o: %.c $(sort $(MAKEFILE_LIST)) $(PRE_TARGETS)
	@echo "C         : $(notdir $<)" $(NOOUT)
	$(call IF_NOT_EXIST_MKDIR,$(@D))
	$(CC) -c $< $(CFLAGS) -Wa,-adhlns="$(@:%.o=%.lst)" -MMD -MP -MF $(@:%.o=%.d) -MT $(@) -o $@

# Build an object file from a C++ file
$(BLD_OUTPUT)/%.o: %.cpp $(sort $(MAKEFILE_LIST)) $(PRE_TARGETS)
	@echo "C++       : $(notdir $<)" $(NOOUT)
	$(call IF_NOT_EXIST_MKDIR,$(@D))
	$(CXX) -c $< $(CXXFLAGS) -Wa,-adhlns="$(@:%.o=%.lst)" -MMD -MP -MF $(@:%.o=%.d) -MT $(@) -o $@

# Build an object file from a C++ file
$(BLD_OUTPUT)/%.o: %.cc $(sort $(MAKEFILE_LIST)) $(PRE_TARGETS)
	@echo "C++       : $(notdir $<)" $(NOOUT)
	$(call IF_NOT_EXIST_MKDIR,$(@D))
	$(CXX) -c $< $(CXXFLAGS) -Wa,-adhlns="$(@:%.o=%.lst)" -MMD -MP -MF $(@:%.o=%.d) -MT $(@) -o $@

# Build an object file from an assembly file filtering through the C pre-processor
$(BLD_OUTPUT)/%.o: %.S $(sort $(MAKEFILE_LIST)) $(PRE_TARGETS)
	@echo "Assembling: $(notdir $<)" $(NOOUT)
	$(call IF_NOT_EXIST_MKDIR,$(@D))
	$(CC) $(AFLAGS) -Wa,-adhlns="$(@:%.o=%.lst)" -MMD -MP -MF $(@:%.o=%.d) -MT $(@) $< -o $@

# Build a list of oject files and library files to link the main elf execautable with
$(BLD_TARGET)-bldeps :=
$(BLD_TARGET)-bldeps += $(addprefix $(BLD_OUTPUT)/,$(patsubst %.S,%.o, $(filter %.S,$(SRC-app))))
$(BLD_TARGET)-bldeps += $(addprefix $(BLD_OUTPUT)/,$(patsubst %.c,%.o, $(filter %.c,$(SRC-app))))
$(BLD_TARGET)-bldeps += $(addprefix $(BLD_OUTPUT)/,$(patsubst %.cpp,%.o, $(filter %.cpp,$(SRC-app))))
$(BLD_TARGET)-bldeps += $(addprefix $(BLD_OUTPUT)/,$(patsubst %.cc,%.o, $(filter %.cc,$(SRC-app))))
$(BLD_TARGET)-bldeps += $(addprefix $(BLD_OUTPUT)/,$(filter %$(LIB_SUFFIX),$(SRC-app)))

# Link an elf file from the list of object files
$(BLD_OUTPUT)/$(BLD_TARGET).elf: $(LNK_SCR) $($(BLD_TARGET)-bldeps) 
	@echo "Link elf  : $@" $(NOOUT)
	$(CC) -o $@ -Wl,-gc-sections -Wl,-Map,$(@:%.elf=%.map),--cref $(LFLAGS) -Wl,--start-group $(if $(LNK_SCR),$(subst $<,,$^),$^) $(EXTRA_LIBS) -Wl,--end-group

# Link an exe from build objects (used for the test target mostly)
$(BLD_OUTPUT)/$(BLD_TARGET): $(LNK_SCR) $($(BLD_TARGET)-bldeps)
	@echo "Link  app : $@" $(NOOUT)
	$(CXX) -o $@ -Xlinker --gc-sections -Wl,-Map,$@.map $(LFLAGS) -Wl,--start-group $(if $(LNK_SCR),$(subst $<,,$^),$^) $(EXTRA_LIBS) -Wl,--end-group

# end of lower
endif

