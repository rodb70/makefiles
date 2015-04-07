#-----------------------------------------------------------------------------
# This is the makefile compiler or cpu target template.  There are 3 parts to 
# this template.  Each file is included 3 times and the INC_PART variable is set
# to upper, middle, lower as needed    
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

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),upper)
# Before target defines
HOSTCC := gcc
HOSTCXX := g++

HOSTCOMFLAGS :=
HOSTCOMFLAGS += -pedantic
HOSTCOMFLAGS += -Wall 
HOSTCOMFLAGS += -Wextra 
HOSTCOMFLAGS += -fstrict-overflow
HOSTCOMFLAGS += -g3

HOSTCFLAGS :=
HOSTCFLAGS += -std=gnu99

HOSTCXXFLAGS :=
HOSTCXXFLAGS += -std=gnu++98

HOSTLFLAGS :=
HOSTLFLAGS += -g3

HOSTCFLAGS += $(HOSTCOMFLAGS)
HOSTCXXFLAGS += $(HOSTCOMFLAGS)
ifeq ($(wildcard $(shell which gcc)),)
$(error Tools C compiler not found)
endif
ifeq ($(wildcard $(shell which g++)),)
$(error Tools C++ compiler not found)
endif

# end of upper
endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),middle)
# After generic targets 

# end of middle
endif

#-----------------------------------------------------------------------------
ifeq ($(INC_PART),lower)
# Bottom of the make file stuff

$(foreach tool,$(TOOLS),$(foreach src,$($(tool)-src),$(eval $(call COMPILE_A_TOOL_O,$(src)))))

$(foreach tool,$(TOOLS),$(eval $(call BUILD_A_TOOL,$(tool))))

#end of lower
endif
