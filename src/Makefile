F90 = gfortran 
FFLAGS= -w -O

# watch out, dependencies make order important here
USER_OBJ = 
SLICE_OBJ = $(USER_OBJ) array_io.o param_mod.o calc_mod.o fwd_mod.o rand_mod.o slice_mod.o
GRID_OBJ = $(USER_OBJ) array_io.o param_mod.o calc_mod.o fwd_mod.o grid_mod.o

all: bin slice grid

bin:
	\mkdir -p ../bin

slice: slice.f90 $(SLICE_OBJ)
	$(F90) $(FFLAGS) -o slice $(SLICE_OBJ) slice.f90
	cp slice ../bin

grid: grid.f90 $(GRID_OBJ)
	$(F90) $(FFLAGS) -o grid $(GRID_OBJ) grid.f90
	cp grid ../bin

%.o : %.f90
	$(F90) $(FFLAGS) -c $*.f90

%.o : %.F
	$(F90) $(FFLAGS) -c $*.F

%.o : %.f
	$(F90) $(FFLAGS) -c $*.f
clean:
	\rm -f *.o *.mod slice ../bin/slice grid ../bin/grid
