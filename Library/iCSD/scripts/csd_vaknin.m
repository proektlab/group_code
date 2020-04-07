function A=csd_vaknin(dane,dist)

% CSD Calculates traditional (Vaknin) CSD of a 3-D matrix
% A = csd_vaknin(B,dist)
% Calculates the numerical Laplacian of the matrix B
% assuming the grid constant (edge length) dist.
% Uses Vaknin procedure.

[nt,nx,ny,nz]=size(dane);

B = bmatrix(nx,ny,nz,'D');
nx = nx+2;
ny = ny+2;
nz = nz+2;
d = zeros(nt,nx,ny,nz);
for i=1:nt
    d(i,:,:,:) = reshape(B*dane(i,:)',nx,ny,nz);
end;

A=d(:,3:nx,2:ny-1,2:nz-1)+d(:,1:nx-2,2:ny-1,2:nz-1);
A=A+d(:,2:nx-1, 3:ny, 2:nz-1)+d(:,2:nx-1, 1:ny-2, 2:nz-1);
A=A+d(:,2:nx-1,2:ny-1,3:nz)+d(:,2:nx-1,2:ny-1,1:nz-2)-6*d(:,2:nx-1,2:ny-1,2:nz-1);
A = - A;
A = A./(dist^2);