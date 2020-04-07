function init_lin(nx,ny,nz)

% Calculates the F matrix for linear approximation

datafolder = 'data';
rmax = 0.2; % Maximal displacement in jittering
n = nx*ny*nz;

if not(exist(fullfile(datafolder, ['F_' ...
        int2str(nx) '_' int2str(ny) '_' int2str(nz) '_lin.mat']),'file'))
    disp(' Generating invF for linear distribution...');
    E = EMatrices(nx,ny,nz);
    F = FdMatrix(nx,ny,nz,[0 0 0]); 
    F = squeeze(F(:,1,:,:));
    Ffinal = zeros(n);
    for i=1:8
        Ffinal = Ffinal + squeeze(F(i,:,:))*squeeze(E(i,:,:));
    end;
    invF=inv(Ffinal); 
    save(fullfile(datafolder, ['F_' ...
        int2str(nx) '_' int2str(ny) '_' int2str(nz) '_lin.mat']), 'invF');
else
    disp(' Generating invF for linear distribution with jittering...');
    filename = fullfile(datafolder, ...
        ['Fd_' int2str(nx) '_' int2str(ny) '_' int2str(nz) '_lin.mat']);
    rand('state', sum(100*clock));
    displ_l = zeros(1,3); 
    
    z = rand*2*rmax-rmax;
    y = rand*2*rmax-rmax;
    x = rand*2*rmax-rmax;

    displ_l(1,3) = z;
    displ_l(1,1) = x;
    displ_l(1,2) = y;
    F = FdMatrix(nx+2,ny+2,nz+2,displ_l); 
        
    E = EMatrices (nx+2,ny+2,nz+2);     

    Ftemp = zeros((nx+2)*(ny+2)*(nz+2));
    F_l = zeros(1, (nx+2)*(ny+2)*(nz+2), (nx+2)*(ny+2)*(nz+2));
    for k=1:8
        Ftemp(:,:) = Ftemp(:,:) + squeeze(F(k,1,:,:))*squeeze(E(k,:,:));
    end;
    F_l(1,:,:) =  Ftemp; 
    
    if exist(filename, 'file')
        load(filename);
        Fd = cat(1,Fd,F_l);
        displacements = cat(1,displacements, displ_l);
    else
        Fd = F_l;
        displacements = displ_l;
    end;
    save(filename, 'Fd', 'displacements');
    
end;


function E=EMatrices (nx,ny,nz)


n = nx*ny*nz; 
m = (nx-1)*(ny-1)*(nz-1); 

E = zeros(8,m,n); 

for i=1:m 
    [xk,yk,zk] = ind2sub([nx-1,ny-1,nz-1],i); 
    
    nr = sub2ind([nx ny nz],xk,yk,zk); 
    nrx = sub2ind([nx ny nz],xk+1,yk,zk); 
    nry = sub2ind([nx ny nz],xk,yk+1,zk);
    nrz = sub2ind([nx ny nz],xk,yk,zk+1);
    nrxy = sub2ind([nx ny nz],xk+1,yk+1,zk);
    nrxz = sub2ind([nx ny nz],xk+1,yk,zk+1);
    nryz = sub2ind([nx ny nz],xk,yk+1,zk+1);
    nrxyz = sub2ind([nx ny nz],xk+1,yk+1,zk+1);
   
    E(1,i,nr) = 1; 
    
    E(2,i,nr) = -1;
    E(2,i,nrx) = 1;
    
    E(3,i,nr) = -1;
    E(3,i,nry) = 1;
    
    E(4,i,nr) = -1;
    E(4,i,nrz) = 1;
    
    E(5,i,nr) = 1;
    E(5,i,nrxy) = 1;
    E(5,i,nrx) = -1;
    E(5,i,nry) = -1;
    
    E(6,i,nr) = 1;
    E(6,i,nrxz) = 1;
    E(6,i,nrx) = -1;
    E(6,i,nrz) = -1;
    
    E(7,i,nr) = 1;
    E(7,i,nryz) = 1;
    E(7,i,nrz) = -1;
    E(7,i,nry) = -1;
    
    E(8,i,nr) = -1;
    E(8,i,nrx) = 1;
    E(8,i,nrz) = 1;
    E(8,i,nry) = 1;
    E(8,i,nrxy) = -1;
    E(8,i,nrxz) = -1;
    E(8,i,nryz) = -1;
    E(8,i,nrxyz) = 1;
end;

function Fd=FdMatrix (nx,ny,nz, dsp)


n = nx*ny*nz; 
m = (nx-1)*(ny-1)*(nz-1); 
dspx = dsp(1,1);
dspy = dsp(1,2);
dspz = dsp(1,3);

Fd = zeros(8,1,n,m); 

F_temp = zeros(8, 2*(nx-1),2*(ny-1), 2*(nz-1));

meter_1 = 2*(nx-1)*2*(ny-1)*2*(nz-1);
counter_1 = 0;

for xp=1:2*(nx-1)
    for yp=1:2*(ny-1)
        for zp=1:2*(nz-1)
            xt = xp - nx + 1;
            yt = yp - ny + 1;
            zt = zp - nz + 1;
                for k = 1:8
                    F_temp(k,xp,yp,zp) = 1/4/pi*triplequad(@(x,y,z) ...
                        fun2(x,y,z,xt-dspx,yt-dspy,zt-dspz,k),0,1,0,1,0,1);
                    
                end;
           
           counter_1 = counter_1 + 1;
           disp([int2str(counter_1) ' of ' int2str(meter_1) ' done']);
        end;
    end;
end;

for j=1:m 
    for i=1:n 
        [xi,yi,zi] = ind2sub([nx,ny,nz],i); 
        [xj,yj,zj] = ind2sub([nx-1,ny-1,nz-1],j); 
        for k=1:8
            Fd(k,1,i,j) = F_temp(k, xi-xj+nx-1, yi-yj+ny-1, zi-zj+nz-1);
        end;
    end;
end;
%%% End of function   

function f = fun2(x,y,z,xt,yt,zt,k)

epsilon = 1e-8;
dist = sqrt( (xt-x).^2+(yt-y)^2+(zt-z)^2); 
for i = 1:length(dist)
    if dist(i)<epsilon
        dist(i) = epsilon;
    end;
end;

invdist = 1./dist;

switch k
    case 1
        f = invdist;
    case 2
        f = x .* invdist;
    case 3
        f = y .* invdist;
    case 4
        f = z .* invdist;
    case 5
        f = x.*y .* invdist;
    case 6
        f = x .*z.* invdist;
    case 7
        f = y.*z.* invdist;
    case 8
        f = x.*y.*z.* invdist;
end;
