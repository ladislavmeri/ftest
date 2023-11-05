# makefile
# build for the flib_ftest package
# L. Meri
###############################################################################

##############################################################
#please edit the PROJ_DIR and FC variables according your system
##############################################################
PROJ_DIR = $(shell pwd)
FC = gfortran

##############################################################
#it is possible to edit the compiler flags but not recommended
##############################################################
FC_FLAGS += -std=f2008 -cpp -Wall -Wextra -pedantic -O0 #-g -pg

##############################################################
#edit external include & library localtions & usage
##############################################################

SRC_DIR = $(PROJ_DIR)/src
MOD_DIR = $(PROJ_DIR)/mod
OBJ_DIR = $(PROJ_DIR)/obj
LIB_DIR = $(PROJ_DIR)/lib
BIN_DIR = $(PROJ_DIR)/bin
INSTALL_PREFIX = $(HOME)/.local
EXT_LIB_DIR = $(INSTALL_PREFIX)/lib
EXT_INC_DIR = $(INSTALL_PREFIX)/include

INC_FLAGS += -J $(MOD_DIR) -I $(EXT_INC_DIR) 
LIB_FLAGS += -L $(LIB_DIR) -lftest 

TARGET_LIB = $(LIB_DIR)/libftest.a 
TARGET_PROG_01 = $(BIN_DIR)/ftest

TARGET_BINS = $(TARGET_PROG_01) 
              
OBJ_LIST = $(OBJ_DIR)/mod_ftest.o 

all : $(TARGET_LIB) $(TARGET_BINS)

clean :
	rm -f $(OBJ_LIST) \
          $(MOD_DIR)/*.mod \
          $(TARGET_LIB) \
          $(TARGET_BINS) 
          
install :
	mkdir -p $(HOME)/.local/lib $(HOME)/.local/include
	cp -f $(TARGET_LIB) $(EXT_LIB_DIR)
	cp -f $(MOD_DIR)/*.mod $(EXT_INC_DIR)
	
test : $(TARGET_LIB) $(TARGET_BINS)
	$(TARGET_PROG_01)
	
ftest : $(TARGET_PROG_01)
	time $(TARGET_PROG_01)
	
$(TARGET_PROG_01) : $(SRC_DIR)/prog_ftest.F90 \
                    $(TARGET_LIB) 
	$(FC) $(FC_FLAGS) $(INC_FLAGS) -o $@ $(SRC_DIR)/prog_ftest.F90 $(LIB_FLAGS)
	
$(TARGET_LIB) : $(OBJ_LIST) 
	$(AR) $(ARFLAGS) $@ $(OBJ_LIST) 

$(OBJ_DIR)/mod_ftest.o : $(SRC_DIR)/mod_ftest.F90  
	$(FC) $(FC_FLAGS) $(INC_FLAGS) -c -o $@ $(SRC_DIR)/mod_ftest.F90
	
	
	
