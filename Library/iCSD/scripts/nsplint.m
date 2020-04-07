function out = nsplint (dane, VX, VY, VZ, E, boundary)

% NSPLINT Natural spline interpolation
% VI = nsplint(data, VX, VY, VZ, boundary)
% Input: data - 3-D matrix of function values at points
% (1,1,1), (2,1,1), ... (nx, ny, nz)
% VX, VY, VZ - these vectors define points at which
% the interpolated values are calculated
% E - the matrix E (see text)
% boundary:
% 'no' or 'S'  - plain interploation using 'data' matrix
% B - interpolation using 'data' matrix with additional layer of zeros
% D - as B but with duplicated values at the additional layer
% For B and D the E matrix should be for the larger grid
% (eg. 6x7x9 instead of 4x5x7)

out = zeros(length(VX),length(VY),length(VZ));
[nx,ny,nz] = size(dane);
A=zeros(4,4,4,(nx-1)*(ny-1)*(nz-1));
if strcmp(boundary, 'no')||strcmp(boundary, 'S')
    for i=1:4
        for j=1:4
            for k=1:4
                A(i,j,k,:)= squeeze(E(i,j,k,:,:))*dane(:);
            end;
        end;
    end;
else
    if strcmp(boundary, 'B')
        B = bmatrix(nx,ny,nz);
    end;
    if strcmp(boundary, 'D')
        B = bmatrix(nx,ny,nz,'D');
    end;
    RA = rmatrix(nx-1, ny-1, nz-1);
    for i=1:4
        for j=1:4
            for k=1:4
                A(i,j,k,:)= RA*squeeze(E(i,j,k,:,:))*B*dane(:);
            end;         
        end;
    end;
end;

for a = 1:length(VX)
    for b = 1:length(VY)
        for c = 1:length(VZ)
            out(a,b,c) = inpol(A, VX(a), VY(b), VZ(c), nx,ny,nz);
        end;
    end;
end;

function value = inpol(A, x,y,z, nx,ny,nz)

bx=0;
by=0;
bz=0;
if x>=nx 
    x = x-1;
    bx = 1;
end;
if y>=ny 
    y = y-1;
    by = 1;
end;
if z>=nz 
    z = z-1;
    bz = 1;
end;

nr = sub2ind([nx-1 ny-1 nz-1],floor(x),floor(y),floor(z)); 

dx = x-floor(x)+bx; 
dy = y-floor(y)+by;
dz = z-floor(z)+bz;

XX(1) = 1-dx;           
XX(2) = dx;             
XX(3) = (XX(1)^3-XX(1))/6;    
XX(4)= (XX(2)^3-XX(2))/6;     
YY(1) = 1-dy;
YY(2) = dy;
YY(3) = (YY(1)^3-YY(1))/6;
YY(4) = (YY(2)^3-YY(2))/6;
ZZ(1) = 1-dz;
ZZ(2) = dz;
ZZ(3) = (ZZ(1)^3-ZZ(1))/6;
ZZ(4) = (ZZ(2)^3-ZZ(2))/6;

value = 0;

for i=1:4
    for j=1:4
        for k=1:4
            value = value + A(k,j,i,nr)*XX(i)*YY(j)*ZZ(k);
        end;
    end;
end;