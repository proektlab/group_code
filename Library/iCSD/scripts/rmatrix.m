function R=rmatrix (nx,ny,nz)

% RMATRIX Calculates the matrix R
% R=rmatrix (nx,ny,nz)
% Calculates the matrix R for nx x ny x nz grid

n = nx*ny*nz; 
M = (nx+2)*(ny+2)*(nz+2); 

R = zeros(n,M); 

for i=1:n 
    [xk,yk,zk] = ind2sub([nx,ny,nz],i); 
    nr = sub2ind([nx+2 ny+2 nz+2],xk+1,yk+1,zk+1); 
    R(i,nr) = 1;
end;
