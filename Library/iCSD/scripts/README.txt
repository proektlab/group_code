MATLAB scripts for calculating 
current source density in 3D
using inverse method

The method is described in the paper
Inverse Current-Source Density Method 
in 3D: Reconstruction Fidelity, Boundary 
Effects, and Influence of Distant Sources

Neuroinformatics 5 (2007), 207-222



1. Installation
Just unpack the files (preserving
the directories structure).

2. Usage
First you have to calculate the appropriate
matrix F. This is done by running one of the 
following scripts:

init_lin(nx,ny,nz)
init_spline(nx,ny,nz)
init_step(nx,ny,nz)

which calculate the matrix F for linear,
spline and step distributions respectively.
The input arguments nx, ny, nz are numbers 
of nodes in each direction. 

Each of these scripts, when run for the first
time, will generate a matrix F assuming
zero displacement vector (no spatial jittering).
If the file with this matrix F already exists
then the script will generate a matrix F 
with random displacement vector and add it to 
the file. 

If you want to use B or D boundary conditions
you need to replace nx, ny, nz by 
nx+2, ny+2, nz+2.

Once you have the needed F matrix (or matrices),
the CSD is calculated by the script icsd. This 
script returns csd only at grid points, so
you need to use interpolate_csd if you want
to obtain values at some other points. 
If you want to use jittering, then you need
to use only one script, jitter, which does
both steps. 

The other scripts in the directory are:
csd		- 'traditional' CSD
csd_vaknin	- as csd but with Vaknin
		  procedure
nsplint		- natural spline interpolation,
		  used by other scripts,
		  (not very efficient)
bmatrix, gmatrix, rmatrix
		- these scrpits genarate
		  B, G and R matrices defined
		  in the paper

rat_movie	- visualization of rat data
		  (run "init_lin(4,5,7);" first)


3. Contact
In case you need more information 
feel free to contact me at
s.leski at nencki.gov.pl


Szymon Leski
10 Jan 2008
