#-----------------------------------------------------------------------------
# This is the main makefile
# 
# Entry system to the embedded makefile build system.  This build system is able 
# to host multi targets and use multi tool chains.  Tool chain build recpies 
# are handled in by make file fragments under the makefiles directory.  The 
# current convention is to start with a CPU architecture and then a compiler 
# name.  For example stm32-gcc - is the ST STM32 cortex M3 family with gcc as 
# the compiler.  Since gcc is a common architecture there is a gcc makefile 
# fragment that is extended by the specific stm32-gcc fragment.  The goal of 
# this is to create an eaisly retargetable build system that is done once and 
# easy to extend.
# This system also makes is easy to make an overriden build like a relese build
# or a test build.
#
# This build system reads in the makefile fragments in this directory 3 times:
# 1. Declare all macros preinitialise makefile variables and create the standard
#    early targets all, clean.
# 2. Reads in all source files for a list of libraries and source files to 
#    build.  Add include paths and variables to compiler parameters.
# 3. Declare implicate and explicate target rules.  include dependencies
# Once this is complete the build is started.
#
# TODO: stuff I want to add
# test target where a build is made for the host that can run tests. DONE
# clean a specific target.
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

#-----------------------------------------------------------------------------
# Include dir paths in makefile system
#-----------------------------------------------------------------------------
.DELETE_ON_ERROR: # Add this to delete target on error
# Path to makefile include files
MAK_PATH := makefiles
include $(MAK_PATH)/paths.mk
#-----------------------------------------------------------------------------
INC_PART := upper
include $(MAK_PATH)/macros.mk

# Prevent bad stuff happening with files
.SUFFIXES:

#-----------------------------------------------------------------------------
# Decleare these all instant expansion
#-----------------------------------------------------------------------------
# To disable automatic linking of gconv for testing build set GCONV_ENABLED to n
# GCONV_ENABLED := n
# PROJ_DIRS - project directory that are included in to the makefile system
PROJ_DIRS := $(PROJ_DIRS)
# CPU - is the name of the CPU being used this must be set for a build to 
# occure but can be set in a system dir makefile 
CPU := $(call TOLOWERCASE,$(CPU))
# COMPILER - is the name of the compiler being used.  again this can be set in
# top level make file or at the system dir level makefile
COMPILER :=  $(call TOLOWERCASE,$(COMPILER))
# BLD_OPTOMISE - The optomise figure to pass to the compiler
BLD_OPTOMISE := $(call TOLOWERCASE,$(BLD_OPTOMISE))
# BLD_TYPE - this is the type of build that is going to occur.  Either debug,
# release, test or what every else is defined
BLD_TYPE :=  $(call TOLOWERCASE,$(BLD_TYPE))
# BLD_MODEL where used the tool chain build model to use. Generally would be one of 
# either small, medium or large but this is tool chain specific
BLD_MODEL := $(call TOLOWERCASE,$(BLD_MODEL))
# BLD_TARGET - name of the target being built.  This is ususlly the application
# name.  This is also used to open a system dir makefile to allow for multi
# targets to be built in one build system.   
BLD_TARGET :=  $(call TOLOWERCASE,$(BLD_TARGET))
# COMFLAGS - flags common to all types of build
COMFLAGS := $(COMFLAGS)
# AFLAGS - assembler flags if used in the makefile system.
AFLAGS := $(AFLAGS)
# CFLAGS - C compiler flags used in the makefile system
CFLAGS := $(CFLAGS)
# CPPFLAGS - C pre-processor flags used in the makefile system (when not gcc)
CPPFLAGS := $(CPPFLAGS)
# CXXFLAGS - C++ compiler flags used in the makefile system
CXXFLAGS := $(CXXFLAGS)
# OCFLAGS - Objcopy flags
OCFLAGS := $(OCFLAGS)
# ODFLAGS - Objdump flags
ODFLAGS := $(ODFLAGS)
# SZFLAGS - size flags
SZFLAGS := $(SZFLAGS)
# LFLAGS - linker flags used in the makefile system
LFLAGS := $(LFLAGS)
# SRC-app - this is the variable that stores source files that are linked
# directly to the target insteat of being built into a library.  This is an 
# internal to the makefile system variable
SRC-app := $(CXXSRC) $(CSRC) $(ASRC)
# LIB-app - list of library names linked into the target
LIB-app :=
# INC - List of include files that is added to the compiler path
INC := $(INC)
# TINC - tool include path used when building tools
TINC := $(TINC)
# DEP-SRC - source files included as dependencies
DEP-SRC :=
# TARGET_OVERRIDE - Used to override the default target to something else in 
# the build system
TARGET_OVERRIDE := n
# TOOLS - List of tools that the build system uses
TOOLS := $(TOOLS)
# List of extra targets to be made when the all target is execauted.  (Add in 
# the upper section of the .mk includes files)
ALL_TARGETS := $(ALL_TARGETS)
# List of targets that are required before making the main binary
PRE_TARGETS := $(PRE_TARGETS)
# If building a boot loader instead of a main application set to y
IS_BOOTLOADER := $(IS_BOOTLOADER)
# Extra libraries to comile against
EXTRA_LIBS := $(EXTRA_LIBS)
# Extra macros defined while reading in source makefile parts and expanded before the build starts
EXTRA_MACROS := $(EXTRA_MACROS)

#-----------------------------------------------------------------------------
# Check an create target override if needed
$(foreach goal,$(MAKECMDGOALS),$(eval $(call MK_OVERRIDE_TARGET,$(goal)))) 
# Set the outout path
BLD_OUTPUT := $(BLD_OUTDIR)/$(BLD_TARGET)/$(CPU)-$(BLD_TYPE)
# Include systems makefile if exists
-include $(SYS_PATH)/$(BLD_TARGET)/Makefile
$(if $(CPU),,$(error CPU not in $(CPU_LIST)))
INC += $(if $(wildcard $(SYS_PATH)/$(BLD_TARGET)/Makefile),$(SYS_PATH)/$(BLD_TARGET))
REALCPU := $(CPU)
ifeq ($(BLD_TYPE),lint)
COMFLAGS += -DLINT_$(call TOUPPERCASE,$(CPU))=1
COMFLAGS += -D__LINT__
override TARGET_SUFFIX :=
endif
ifeq ($(BLD_TYPE),test)
COMFLAGS += -DTEST_$(call TOUPPERCASE,$(CPU))=1
CPU := host
COMPILER := gcc
override TARGET_SUFFIX :=
override BLD_OUTPUT := $(BLD_OUTDIR)/$(BLD_TARGET)/$(CPU)-$(BLD_TYPE)
COMFLAGS += -DTEST_HARNESS=1
endif
ifeq ($(COMPILER),)
COMPILER := $(if $($(call TOUPPERCASE,$(CPU))_COMPILER),$($(call TOUPPERCASE,$(CPU))_COMPILER),$(error compiler not set for $(CPU)))
endif
ifeq ($(BLD_TYPE),debug)
# Add debug specific global flags here
#AFLAGS += 
#CFLAGS += 
#CXXFLAGS += 
endif
ifeq ($(BLD_TYPE),release)
# Add release specific global flags here
#AFLAGS += 
# Switch off asserts
CFLAGS += -DNDEBUG
CXXFLAGS += -DNDEBUG
endif
ifeq ($(filter $(BLD_TYPE),$(BLD_TYPE_LIST)),)
$(error BLD_TYPE set to $(if $(BLD_TYPE),$(BLD_TYPE) is not defined,nothing) try: $(subst $(SPACE),$(COMMA),$(BLD_TYPE_LIST)))
endif
COMFLAGS += $(if $(CPU),-D$(call TOUPPERCASE,$(CPU))=1)
COMFLAGS += $(if $(BOARD),-D$(call TOUPPERCASE,$(BOARD))=1)

include $(MAK_PATH)/$(CPU)-$(COMPILER).mk 
include $(MAK_PATH)/tool-$(HOSTARCH).mk 


# New improved verbose mode
V ?= 0
ifeq ($(V),1)
NOOUT := > /dev/null
else
MAKEFLAGS += -s
endif

.PHONY: all
all: tools $(BLD_OUTPUT)/$(BLD_TARGET)$(TARGET_SUFFIX) | $(ALL_TARGETS)

.PHONY: clean
clean :
	@echo "Cleaning" $(NOOUT)
	rm -rf $(dir $(BLD_OUTPUT))


#-----------------------------------------------------------------------------
INC_PART := middle
include $(MAK_PATH)/macros.mk 
include $(MAK_PATH)/$(CPU)-$(COMPILER).mk 
include $(MAK_PATH)/tool-$(HOSTARCH).mk 

# Add global include path at the end of all other files 
ifneq ($(wildcard $(SRC_PATH)/include),)
PROJ_DIRS += $(SRC_PATH)/include
endif
# Read in source files to build
$(foreach dir,$(strip $(PROJ_DIRS)),$(eval $(call MK_PROJECT,$(dir))))
$(foreach dir,$(strip $(PROJ_DIRS)),$(if $(wildcard $(dir)/$(REALCPU)),$(eval $(call MK_PROJECT,$(dir)/$(REALCPU)))))
ifeq ($(BLD_TYPE),test)
$(foreach dir,$(strip $(PROJ_DIRS)),$(if $(wildcard $(dir)/test),$(eval $(call MK_PROJECT,$(dir)/test))))
else
endif
.PHONY: tools
tools: $(addprefix ./$(BLD_OUTPUT)/bin/,$(TOOLS))

#-----------------------------------------------------------------------------
INC_PART := lower
# Bottom of the make file stuff
AFLAGS += $(addprefix -I ,$(INC))
CFLAGS += $(addprefix -I ,$(INC))
CXXFLAGS += $(addprefix -I ,$(INC))
CPPFLAGS += $(addprefix -I ,$(INC))
HOSTCFLAGS += $(addprefix -I ,$(TINC))

include $(MAK_PATH)/macros.mk 
include $(MAK_PATH)/$(CPU)-$(COMPILER).mk 
include $(MAK_PATH)/tool-$(HOSTARCH).mk 

$(foreach macro,$(EXTRA_MACROS),$(eval $(call $(macro))))

#-----------------------------------------------------------------------------
# Do auto dependencies like http://make.paulandlesley.org/autodep.html
DEP-SRC += $(filter %.c,$(SRC-app))
DEP-SRC += $(filter %.c,$(SRC_MAIN))
DEP-SRC += $(filter %.cc,$(SRC-app))
DEP-SRC += $(filter %.cpp,$(SRC-app))
DEP-SRC += $(foreach lib,$(LIB-app),$(SRC-$(lib)))
DEP-SRC += $(foreach tool,$(TOOLS),$($(tool)-src))
DEP-SRC := $(patsubst %.c,%.d,$(DEP-SRC))
DEP-SRC := $(patsubst %.cc,%.d,$(DEP-SRC))
DEP-SRC := $(patsubst %.cpp,%.d,$(DEP-SRC))
DEP-SRC := $(addprefix $(BLD_OUTPUT)/,$(DEP-SRC))
DEP-SRC := $(strip $(DEP-SRC))
-include $(DEP-SRC)

