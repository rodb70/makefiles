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

#end of lower
endif