#-----------------------------------------------------------------------------
# PC-Lint makefile stuff     
# upper:
# This is here CPU or compiler specific make defines CFLAGS, AFLAGS, LFLAGS 
# and any other CPU or compiler specific defines are declared here.
#
# middle:
# This is included after the global targets of all, clean extra CPU or compiler
# specific global targets can be created here.
#
# lower:
# implicat rules for the compiler are created here

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

LINT_CC := gcc
$(if $(call PATHSEARCH,$(LINT_CC)),,$(error gcc not found cannot preprocess code))

# Script file to run lint
LINT_EXE := $(call PATHSEARCH,lint.sh)

PRE_TARGETS += $(BLD_OUTPUT)/lint_cmac.h $(BLD_OUTPUT)/lint_cppmac.h $(BLD_OUTPUT)/gcc-include-path.lnt
PRE_TARGETS += $(BLD_OUTPUT)/size-options.lnt
 
# Used to only have one library declaration
LIB_SRC_LIST :=
# Macro to generate library build rules 
define GEN_SRC_LIST
LIB_SRC_LIST += $$(filter %.c,$$(SRC-$(1)))
LIB_SRC_LIST += $$(filter %.cpp,$$(SRC-$(1)))
LIB_SRC_LIST += $$(filter %.cc,$$(SRC-$(1)))

endef
# end of upper
endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),middle)
# After generic targets 
MAIN_CXX := $(CROSS_COMPILE)g++
MAIN_CC := $(CROSS_COMPILE)gcc

LINT_ECHO:=echo
LINT_TOUCH:=touch
LINT_AWK:=awk

# end of middle
endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),lower)
# Add common flags to the C and CPP flags list
CFLAGS += $(COMFLAGS)
CXXFLAGS += $(COMFLAGS)

E := empty

$(BLD_OUTPUT)/lint_cmac.h: $(BLD_OUTPUT)/gcc-include-path.lnt $(BLD_OUTPUT)/lint_cppmac.h
	$(call IF_NOT_EXIST_MKDIR,$(@D))
	set -e ; $(LINT_TOUCH) $(E)$$$$.c ; $(MAIN_CC) -E -dM $(E)$$$$.c -o $@ ; $(RM) $(E)$$$$.c

$(BLD_OUTPUT)/lint_cppmac.h:
	$(call IF_NOT_EXIST_MKDIR,$(@D))
	set -e ; $(LINT_TOUCH) $(E)$$$$.cpp ; $(MAIN_CXX) -E -dM $(E)$$$$.cpp -o $@ ; $(RM) $(E)$$$$.cpp

$(BLD_OUTPUT)/gcc-include-path.lnt:
	$(call IF_NOT_EXIST_MKDIR,$(@D))
	$(LINT_TOUCH) $(E)$$$$.cpp ; \
	$(MAIN_CXX) -v -c $(E)$$$$.cpp >$(E)$$$$.tmp 2>&1 ; \
	<$(E)$$$$.tmp $(LINT_AWK) ' \
	    BEGIN  {S=0} \
	    /search starts here:/  {S=1;next;} \
	    S && /Library\/Frameworks/ {next;} \
	    S && /^ /  { \
	    sub("^ ",""); \
	    gsub("//*","/"); \
	    sub("\xd$$",""); \
	    sub("/$$",""); \
	    printf("--i\"%s\"\n", $$0); \
	    next; \
	    } \
	    S  {exit;} \
	    ' >$@ ; \
	$(RM) $(E)$$$$.cpp $(E)$$$$.tmp $(E)$$$$.o

$(BLD_OUTPUT)/size-options.lnt: $(BLD_OUTPUT)/lint_cmac.h
	$(call IF_NOT_EXIST_MKDIR,$(@D))
	@$(LINT_ECHO) '/__SIZEOF_SHORT__/ {' > $@.awk
	@$(LINT_ECHO) 'sizeof_short=$$3' >> $@.awk
	@$(LINT_ECHO) '}' >> $@.awk
	@$(LINT_ECHO) '/__SIZEOF_INT__/ {' >> $@.awk
	@$(LINT_ECHO) 'sizeof_int=$$3' >> $@.awk
	@$(LINT_ECHO) '}' >> $@.awk
	@$(LINT_ECHO) '/__SIZEOF_LONG__/ {' >> $@.awk
	@$(LINT_ECHO) 'sizeof_long=$$3' >> $@.awk
	@$(LINT_ECHO) '}' >> $@.awk
	@$(LINT_ECHO) '/__SIZEOF_LONG_LONG__/ {' >> $@.awk
	@$(LINT_ECHO) 'sizeof_long_long=$$3' >> $@.awk
	@$(LINT_ECHO) '}' >> $@.awk
	@$(LINT_ECHO) '/__SIZEOF_FLOAT__/ {' >> $@.awk
	@$(LINT_ECHO) 'sizeof_float=$$3' >> $@.awk
	@$(LINT_ECHO) '}' >> $@.awk
	@$(LINT_ECHO) '/__SIZEOF_DOUBLE__/ {' >> $@.awk
	@$(LINT_ECHO) 'sizeof_double=$$3' >> $@.awk
	@$(LINT_ECHO) '}' >> $@.awk
	@$(LINT_ECHO) '/__SIZEOF_LONG_DOUBLE__/ {' >> $@.awk
	@$(LINT_ECHO) 'sizeof_long_double=$$3' >> $@.awk
	@$(LINT_ECHO) '}' >> $@.awk
	@$(LINT_ECHO) '/__SIZEOF_PTRDIFF_T__/ {' >> $@.awk
	@$(LINT_ECHO) 'sizeof_void_star=$$3' >> $@.awk
	@$(LINT_ECHO) '}' >> $@.awk
	@$(LINT_ECHO) '/__SIZEOF_WCHAR_T__/ {' >> $@.awk
	@$(LINT_ECHO) 'sizeof_wchar_t=$$3' >> $@.awk
	@$(LINT_ECHO) '}' >> $@.awk
	@$(LINT_ECHO) 'END {' >> $@.awk
	@$(LINT_ECHO) 'printf "-ss%d -si%d -sl%d -sll%d -sf%d -sd%d -sld%d -sp%d -sw%d",sizeof_short, sizeof_int, sizeof_long,' >> $@.awk
	@$(LINT_ECHO) 'sizeof_long_long, sizeof_float, sizeof_double, sizeof_long_double, sizeof_void_star, sizeof_wchar_t' >> $@.awk
	@$(LINT_ECHO) '}' >> $@.awk
	$(LINT_AWK) -f $@.awk < $^ > $@
	echo "" >> $@

# Bottom of the make file stuff
$(BLD_OUTPUT)/$(BLD_TARGET): $(sort $(MAKEFILE_LIST)) $(PRE_TARGETS) $(BLD_OUTPUT)/flint_done

$(foreach lib,$(LIB-app),$(eval $(call GEN_LIBS,$(lib))))
$(BLD_TARGET)-bldeps :=
$(BLD_TARGET)-bldeps += $(filter %.c,$(SRC-app))
$(BLD_TARGET)-bldeps += $(filter %.cpp,$(SRC-app))
$(BLD_TARGET)-bldeps += $(filter %.cc,$(SRC-app))
$(BLD_TARGET)-bldeps += $(filter %.c,$(LIB_SRC_LIST))
$(BLD_TARGET)-bldeps += $(filter %.cpp,$(LIB_SRC_LIST))
$(BLD_TARGET)-bldeps += $(filter %.cc,$(LIB_SRC_LIST))

# Link an elf file from the list of object files
$(BLD_OUTPUT)/$(BLD_TARGET).pp: $($(BLD_TARGET)-bldeps)
	$(call IF_NOT_EXIST_MKDIR,$(@D))
	@echo "Lint      : $@" $(NOOUT)
	$(LINT_CC)  -E $(CFLAGS) $(CXXFLAGS) $^ > $@

$(BLD_OUTPUT)/flint_done: $(BLD_OUTPUT)/size-options.lnt $($(BLD_TARGET)-bldeps)
	$(LINT_EXE) -i$(BLD_OUTPUT) -isource/lint std.lnt env-gcc.lnt -u -b $(addprefix -i,$(INC)) $(filter-out %.lnt,$^)
#	awk -f unique.awk flint.err > flint_unique.err
	
#end of lower
endif
