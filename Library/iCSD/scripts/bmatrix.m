function B=bmatrix (nx,ny,nz,varargin)

% BMATRIX Calculates the matrix B.
% B=bmatrix (nx,ny,nz,varargin)
% Calculates the matrix B for nx x ny x nz grid
% If optional fourth argument 'D' is given, 
% this is the B(D) matrix

if isempty(varargin) 
    zero_bd = 1;
else
    zero_bd = 0;
end;

n = nx*ny*nz; 
M = (nx+2)*(ny+2)*(nz+2); 

B = zeros(M,n); 

if zero_bd
    for i=1:M 
        [xk,yk,zk] = ind2sub([nx+2,ny+2,nz+2],i); 
        if (xk==1)||(yk==1)||(zk==1)||(xk==(nx+2))||(yk==(ny+2))||(zk==(nz+2))
        else
            nr = sub2ind([nx ny nz],xk-1,yk-1,zk-1); 
            B(i,nr) = 1;
        end;
    end;
else
    for i=1:M 
        [xk,yk,zk] = ind2sub([nx+2,ny+2,nz+2],i); 
        if (xk==1)||(yk==1)||(zk==1)||(xk==(nx+2))||(yk==(ny+2))||(zk==(nz+2))
            if (xk==1)||(xk==(nx+2))
                if yk==1
                    yk=2;
                end;
                if yk==(ny+2)
                    yk=ny+1;
                end;
                if zk==1
                    zk=2;
                end;
                if zk==(nz+2)
                    zk=nz+1;
                end;
                if (xk==1)
                    nr = sub2ind([nx ny nz],1,yk-1,zk-1); 
                else
                    nr = sub2ind([nx ny nz],nx,yk-1,zk-1); 
                end;
                B(i,nr) = 1;
            elseif (yk==1)||(yk==(ny+2))
                if zk==1
                    zk=2;
                end;
                if zk==(nz+2)
                    zk=nz+1;
                end;
                if (yk==1)
                    nr = sub2ind([nx ny nz],xk-1,1,zk-1); 
                else
                    nr = sub2ind([nx ny nz],xk-1,ny,zk-1); 
                end;
                B(i,nr) = 1;
            else
                if (zk==1)
                    nr = sub2ind([nx ny nz],xk-1,yk-1,1); 
                else
                    nr = sub2ind([nx ny nz],xk-1,yk-1,nz); 
                end;
                B(i,nr) = 1;
            end;
        else
            nr = sub2ind([nx ny nz],xk-1,yk-1,zk-1); 
            B(i,nr) = 1;
        end;
    end;
end;