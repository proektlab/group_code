function A=csd(B,dist)

% CSD Calculates traditional CSD of a 3-D matrix
% A = csd(B,dist)
% Calculates the numerical Laplacian of the matrix B
% assuming the grid constant (edge length) dist

[nt,nx,ny,nz]=size(B);

A=B(:,3:nx,2:ny-1,2:nz-1)+B(:,1:nx-2,2:ny-1,2:nz-1);
A=A+B(:,2:nx-1, 3:ny, 2:nz-1)+B(:,2:nx-1, 1:ny-2, 2:nz-1);
A=A+B(:,2:nx-1,2:ny-1,3:nz)+B(:,2:nx-1,2:ny-1,1:nz-2)-6*B(:,2:nx-1,2:ny-1,2:nz-1);
A = - A;
A = A./(dist^2);