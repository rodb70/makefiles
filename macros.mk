#-----------------------------------------------------------------------------
# Global macros for build system 
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

EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
COMMA := $(EMPTY),$(EMPTY)

BLD_TYPE_LIST := debug release test clean lint

__get_word=$(word $(1),$(2))
GET_BUILD=$(call __get_word,1,$(subst _, ,$(1)))
GET_CPU_RAW=$(call __get_word,2,$(subst _, ,$(1)))
GET_CPU=$(if $(CPU_LIST),$(filter $(call GET_CPU_RAW,$(1)),$(CPU_LIST)),$(call GET_CPU_RAW,$(1)))
GET_TARGET=$(call __get_word,3,$(subst _, ,$(1)))

# test if build type wants debug added to build
IS_DEBUG=$(if $(findstring $(1),debug test),y,n)

#-----------------------------------------------------------------------------
# Given a directory open the makefile.mk file and read the contents
# $1 - path to source
define MK_PROJECT
CXXSRC :=
CSRC :=
ASRC :=
TSRC :=
LIB :=
TOOL :=
ADD_TO_INC_PATH := n
FPATH := $(1)
include $(1)/Makefile
FPATH := $$(EMPTY)
ifneq ($$(TOOL),)
$$(TOOL)-src := $$($$(TOOL)-src)
$$(TOOL)-src += $$(strip $$(addprefix $(1)/,$$(strip $$(TSRC))))
TOOLS += $$(TOOL)
ifeq ($$(ADD_TO_INC_PATH),y)
TINC += $1
endif # add to path
else # tool
sub := -app
ifneq ($$(LIB),)
sub := -$$(LIB)
SRC-app += $$(strip $(LIB_PREFIX)$$(LIB)$(LIB_SUFFIX))
LIB-app += $$(strip $$(LIB))
SRC$$(sub) := $$(strip $$(SRC$$(sub)))
endif # lib
SRC$$(sub) += $$(strip $$(addprefix $(1)/,$$(strip $$(ASRC) $$(CSRC) $$(CXXSRC))))
ifeq ($$(ADD_TO_INC_PATH),y)
INC += $1
endif # add to path
endif # tool
endef

#-----------------------------------------------------------------------------
# A build override is a target in the form of <BLD_TYPE>_<CPU>_<target name>
# if must be the only parameter passed to this macro.
# Basically check if there are 3 parts to the target.
#
# $1 - target to test
__target_test=$(words $(subst _, ,$(1))) 

#-----------------------------------------------------------------------------
# Make an override target if passed to the command line 
# $1 - the rule to test
define MK_OVERRIDE_TARGET
ifeq ($(call __target_test,$(1)),3)
ifeq ($(TARGET_OVERRIDE),y)
$$(error TARGET_OVERRIDE already set you can only have 1)
endif
BLD_TYPE := $$(call GET_BUILD,$(1))
CPU := $$(call GET_CPU,$(1))
BLD_TARGET := $$(call GET_TARGET,$(1))
.PHONY: $$(BLD_TYPE)_$$(CPU)_$$(BLD_TARGET)
ifneq ($$(BLD_TYPE),clean)
$$(BLD_TYPE)_$$(CPU)_$$(BLD_TARGET): all
else
$$(BLD_TYPE)_$$(CPU)_$$(BLD_TARGET): clean
endif
TARGET_OVERRIDE := y
endif 
endef

#-----------------------------------------------------------------------------
# If a directory does not exist create it.
# This is interesting to verify by changing the shell to an info and manually
# making some for the dirs needed for the build it is possible to see when the
# mkdir is required by seeing the build failure on missing dir.
# NOTE: should only be use in rules.
#
# 1 - the directory to check
IF_NOT_EXIST_MKDIR=$(if $(wildcard $(1)),,$(shell mkdir -p $(1)))

#-----------------------------------------------------------------------------
# Convert to lower case
TOLOWERCASE = $(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$1))))))))))))))))))))))))))

#-----------------------------------------------------------------------------
# Convert to Upper case
TOUPPERCASE = $(subst a,A,$(subst b,B,$(subst c,C,$(subst d,D,$(subst e,E,$(subst f,F,$(subst g,G,$(subst h,H,$(subst i,I,$(subst j,J,$(subst k,K,$(subst l,L,$(subst m,M,$(subst n,N,$(subst o,O,$(subst p,P,$(subst q,Q,$(subst r,R,$(subst s,S,$(subst t,T,$(subst u,U,$(subst v,V,$(subst w,W,$(subst x,X,$(subst y,Y,$(subst z,Z,$1))))))))))))))))))))))))))

#-----------------------------------------------------------------------------
# Search for object in application path
# 1 - execautable to search for
PATHSEARCH = $(firstword $(wildcard $(addsuffix /$(1),$(subst :, ,$(PATH)))))

GET_COMPILER = $(if $(subst lint,,$(BLD_TYPE)),$(COMPILER),lint)

#------------------------------------------------------------------------------
# Figure out host architecture
HOSTARCH := $(call TOLOWERCASE,$(shell uname -s))
ifeq ($(HOSTARCH),)
HOSTARCH := $(strip $(firstword $(subst _, ,$(OS))))
endif
ifeq ($(HOSTARCH),)
$(error Cannot identify OS make is running from)
endif
ifeq ($(HOSTARCH),Windows)
$(error ($(HOSTARCH) not fully supported)
endif

#-----------------------------------------------------------------------------
# Build a tool that is required by the build system
#
# 1 - The name of the tool
define BUILD_A_TOOL
$(1) := ./$(BLD_OUTPUT)/bin/$(1) 
$$($(1)): $$(addprefix $$(BLD_OUTPUT)/,$$($(1)-src:.c=.o))
	@echo "Host build: $$(notdir $$@)" $$(NOOUT)
	$$(call IF_NOT_EXIST_MKDIR,$$(@D))
	$(HOSTCC) $(HOSTLFLAGS) -Wl,-Map,$$@.map -Wl,--start-group $$^ $$(TOOL_LIBS) -Wl,--end-group -o $$@ 

endef

# Compile a tool
# 1 - the C file to compile
define COMPILE_A_TOOL_O
$(BLD_OUTPUT)/$(1:.c=.o): $(1) $(PRE_TARGETS)
	@echo "Host CC   : $$(notdir $$@)" $$(NOOUT)
	$$(call IF_NOT_EXIST_MKDIR,$$(@D))
	$(HOSTCC) $(HOSTCFLAGS) -Wa,-adhlns="$$(@:.o=.lst)" -MMD -MP -MF $$(@:.o=.d) -MT $$@ -c $$< -o $$@
endef

# end of upper macros section
endif
