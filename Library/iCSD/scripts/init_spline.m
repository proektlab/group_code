function init_spline(nx,ny,nz)

% Calculates the F matrix for spline approximation

datafolder = 'data';
rmax = 0.2; % Maximal displacement in jittering
n = nx*ny*nz;

suffix = ['_' int2str(nx) '_' int2str(ny) '_' int2str(nz) ...
        '_spline'];
suffix2 = ['_' int2str(nx+2) '_' int2str(ny+2) '_' int2str(nz+2) ...
        '_spline'];
n_end = 'n.mat';
m_end = 'm.mat';


if not(exist(fullfile(datafolder, ['E' suffix n_end]),'file'))
    ESpMatrices(nx,ny,nz,'n');
end;
if not(exist(fullfile(datafolder, ['E' suffix m_end]),'file'))
    ESpMatrices(nx,ny,nz,'m');
end;

if not(exist(fullfile(datafolder, ['F' suffix n_end]),'file'))||not(exist(fullfile(datafolder, ['F' suffix m_end]),'file'))
    disp(' Generating invF for spline distribution...');
    load(fullfile(datafolder, ['E' suffix n_end]));
    En = E;
    load(fullfile(datafolder, ['E' suffix m_end]));
    Em = E;
    clear E;
    F = FdSpMatrix(nx,ny,nz,[0 0 0]); 
    Ftempn = zeros(n);
    Ftempm = zeros(n);
    for i=1:4
        for j=1:4
            for k=1:4
                Ftempn = Ftempn + squeeze(F(i,j,k,:,:))*squeeze(En(i,j,k,:,:));
                Ftempm = Ftempm + squeeze(F(i,j,k,:,:))*squeeze(Em(i,j,k,:,:));
            end;
        end;
    end;
    invFn=inv(Ftempn); 
    invFm=inv(Ftempm); 
    invF=invFn;
    save(fullfile(datafolder, ['F' suffix n_end]), 'invF');
    invF=invFm;
    save(fullfile(datafolder, ['F' suffix m_end]), 'invF');
else
    disp(' Generating invF for spline distribution with jittering...');
    rand('state', sum(100*clock));
    displ_l = zeros(1,3); 
    z = rand*2*rmax-rmax;
    y = rand*2*rmax-rmax;
    x = rand*2*rmax-rmax;
    displ_l(1,3) = z;
    displ_l(1,1) = x;
    displ_l(1,2) = y;
       
    F = FdSpMatrix(nx+2,ny+2,nz+2,displ_l); 
    
    if not(exist(fullfile(datafolder, ['E' suffix2 n_end]), 'file'))
        ESpMatrices(nx+2,ny+2,nz+2,'n');
    end;
    if not(exist(fullfile(datafolder, ['E' suffix2 m_end]), 'file'))
        ESpMatrices(nx+2,ny+2,nz+2,'m');
    end;
    load(fullfile(datafolder, ['E' suffix2 n_end]));
    En = E;
    load(fullfile(datafolder, ['E' suffix2 m_end]));
    Em = E;
    clear E;
    
    Ftempn = zeros((nx+2)*(ny+2)*(nz+2));
    Ftempm = zeros((nx+2)*(ny+2)*(nz+2));
    F_ln = zeros(1, (nx+2)*(ny+2)*(nz+2), (nx+2)*(ny+2)*(nz+2));
    F_lm = zeros(1, (nx+2)*(ny+2)*(nz+2), (nx+2)*(ny+2)*(nz+2));
    for i=1:4
        for j=1:4
            for k=1:4
                Ftempn = Ftempn + squeeze(F(i,j,k,:,:))*squeeze(En(i,j,k,:,:));
                Ftempm = Ftempm + squeeze(F(i,j,k,:,:))*squeeze(Em(i,j,k,:,:));
            end;
        end;
    end;
    F_ln(1,:,:) =  Ftempn; 
    F_lm(1,:,:) =  Ftempm;
    
    filename_n = fullfile(datafolder, ['Fd' suffix n_end]);
    filename_m = fullfile(datafolder, ['Fd' suffix m_end]);
    if exist(filename_n, 'file')
        load(filename_n);
        Fd = cat(1,Fd,F_ln);
        displacements = cat(1,displacements, displ_l);
    else
        Fd = F_ln;
        displacements = displ_l;
    end;
    save(filename_n, 'Fd', 'displacements');
    if exist(filename_m, 'file')
        load(filename_m);
        Fd = cat(1,Fd,F_lm);
        displacements = cat(1,displacements, displ_l);
    else
        Fd = F_lm;
        displacements = displ_l;
    end;
    save(filename_m, 'Fd', 'displacements');
end;


function Fd=FdSpMatrix (nx,ny,nz, dsp)

n = nx*ny*nz; 
m = (nx-1)*(ny-1)*(nz-1); 
dspx = dsp(1,1);
dspy = dsp(1,2);
dspz = dsp(1,3);

Fd = zeros(4,4,4,n,m); 

F_temp = zeros(8, 2*(nx-1),2*(ny-1), 2*(nz-1));

meter_1 = 2*(nx-1)*2*(ny-1)*2*(nz-1);
counter_1 = 0;

for xp=1:2*(nx-1)
    for yp=1:2*(ny-1)
        for zp=1:2*(nz-1)
            xt = xp - nx + 1;
            yt = yp - ny + 1;
            zt = zp - nz + 1;
                for a = 1:4
                    for b = 1:4
                        for c = 1:4
                            F_temp(a,b,c,xp,yp,zp) = ... 
                                1/4/pi*triplequad(@(x,y,z) ...
                                funSp(x,y,z, ...
                                xt-dspx,yt-dspy,zt-dspz, ... 
                                a, b, c), 0,1,0,1,0,1);
                        end;
                    end;
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
        for a=1:4
            for b=1:4
                for c=1:4
                    Fd(a,b,c,i,j) = F_temp(a,b,c, xi-xj+nx-1, yi-yj+ny-1, zi-zj+nz-1);
                end;
            end;
        end;
    end;
end;
%%% End of function   


function E=ESpMatrices (nx,ny,nz,method)
datafolder = 'data';
suffix = ['_' int2str(nx) '_' int2str(ny) '_' int2str(nz) ...
        '_spline' method '.mat'];

n = nx*ny*nz; 
m = (nx-1)*(ny-1)*(nz-1); 

E = zeros(4,4,4,m,n); 
Gx = gmatrix(nx,method);
Gy = gmatrix(ny,method);
Gz = gmatrix(nz,method);

for ii=1:m  
            
    disp(['  Calculating E-spline matrices, ' int2str(ii) ' of ' int2str(m)]);
    [xk,yk,zk] = ind2sub([nx-1,ny-1,nz-1],ii); 
    nr = sub2ind([nx ny nz],xk,yk,zk); 
    nrx = sub2ind([nx ny nz],xk+1,yk,zk); 
    nry = sub2ind([nx ny nz],xk,yk+1,zk);
    nrz = sub2ind([nx ny nz],xk,yk,zk+1);
    nrxy = sub2ind([nx ny nz],xk+1,yk+1,zk);
    nrxz = sub2ind([nx ny nz],xk+1,yk,zk+1);
    nryz = sub2ind([nx ny nz],xk,yk+1,zk+1);
    nrxyz = sub2ind([nx ny nz],xk+1,yk+1,zk+1);
    E(1,1,1, ii, nr) = 1;
    E(1,1,2, ii, nrx) = 1;
    E(1,2,1, ii, nry) = 1;
    E(1,2,2, ii, nrxy) = 1;
    for i=1:nx
        pk = sub2ind([nx ny nz],i,yk,zk);
        E(1,1,3, ii, pk) = Gx(xk, i);
        E(1,1,4, ii, pk) = Gx(xk+1, i);
        pky = sub2ind([nx ny nz],i,yk+1,zk);
        E(1,2,3, ii, pky) = Gx(xk, i);
        E(1,2,4, ii, pky) = Gx(xk+1, i);
    end;
    for i=1:ny
        pk = sub2ind([nx ny nz],xk,i,zk);
        pkx = sub2ind([nx ny nz],xk+1,i,zk);
        E(1,3,1, ii, pk) = Gy(yk, i);
        E(1,3,2, ii, pkx) = Gy(yk, i);
        E(1,4,1, ii, pk) = Gy(yk+1, i);
        E(1,4,2, ii, pkx) = Gy(yk+1, i);
    end;
    for i=1:ny
        for l=1:nx
            pk = sub2ind([nx ny nz], l, i, zk);
            E(1,3,3, ii, pk) = Gx(xk, l)*Gy(yk, i);
            E(1,3,4, ii, pk) = Gx(xk+1, l)*Gy(yk, i);
            E(1,4,3, ii, pk) = Gx(xk, l)*Gy(yk+1, i);
            E(1,4,4, ii, pk) = Gx(xk+1, l)*Gy(yk+1, i);
        end;
    end;
    E(2,1,1, ii, nrz) = 1;
    E(2,1,2, ii, nrxz) = 1;
    E(2,2,1, ii, nryz) = 1;
    E(2,2,2, ii, nrxyz) = 1;
    for i=1:nx
        pkz = sub2ind([nx ny nz],i,yk,zk+1);
        pkyz = sub2ind([nx ny nz],i,yk+1,zk+1);
        E(2,1,3, ii, pkz) = Gx(xk, i);
        E(2,1,4, ii, pkz) = Gx(xk+1, i);
        E(2,2,3, ii, pkyz) = Gx(xk, i);
        E(2,2,4, ii, pkyz) = Gx(xk+1, i);
    end;
    for i=1:ny
        pk = sub2ind([nx ny nz],xk,i,zk+1);
        pkx = sub2ind([nx ny nz],xk+1,i,zk+1);
        E(2,3,1, ii, pk) = Gy(yk, i);
        E(2,3,2, ii, pkx) = Gy(yk, i);
        E(2,4,1, ii, pk) = Gy(yk+1, i);
        E(2,4,2, ii, pkx) = Gy(yk+1, i);
    end;
    for i=1:ny
        for l=1:nx
            pk = sub2ind([nx ny nz], l, i, zk+1);
            E(2,3,3, ii, pk) = Gx(xk, l)*Gy(yk, i);
            E(2,3,4, ii, pk) = Gx(xk+1, l)*Gy(yk, i);
            E(2,4,3, ii, pk) = Gx(xk, l)*Gy(yk+1, i);
            E(2,4,4, ii, pk) = Gx(xk+1, l)*Gy(yk+1, i);
        end;
    end;
    for i=1:nz
        pk = sub2ind([nx ny nz],xk,yk,i);
        pkx = sub2ind([nx ny nz],xk+1,yk,i);
        pky = sub2ind([nx ny nz],xk,yk+1,i);
        pkxy = sub2ind([nx ny nz],xk+1,yk+1,i);
        E(3,1,1, ii, pk) = Gz(zk, i);
        E(3,1,2, ii, pkx) = Gz(zk, i);
        E(3,2,1, ii, pky) = Gz(zk, i);
        E(3,2,2, ii, pkxy) = Gz(zk, i);
        E(4,1,1, ii, pk) = Gz(zk+1, i);
        E(4,1,2, ii, pkx) = Gz(zk+1, i);
        E(4,2,1, ii, pky) = Gz(zk+1, i);
        E(4,2,2, ii, pkxy) = Gz(zk+1, i);
    end;    
    for l=1:nz
        for i=1:nx
            pk = sub2ind([nx ny nz], i, yk, l);
            pky = sub2ind([nx ny nz], i, yk+1, l);
            E(3,1,3, ii, pk) = Gz(zk, l)*Gx(xk, i);
            E(3,1,4, ii, pk) = Gz(zk, l)*Gx(xk+1, i);
            E(3,2,3, ii, pky) = Gz(zk, l)*Gx(xk, i);
            E(3,2,4, ii, pky) = Gz(zk, l)*Gx(xk+1, i);
            E(4,1,3, ii, pk) = Gz(zk+1, l)*Gx(xk, i);
            E(4,1,4, ii, pk) = Gz(zk+1, l)*Gx(xk+1, i);
            E(4,2,3, ii, pky) = Gz(zk+1, l)*Gx(xk, i);
            E(4,2,4, ii, pky) = Gz(zk+1, l)*Gx(xk+1, i);
        end;
    end;
    for l=1:nz
        for i=1:ny
            pk = sub2ind([nx ny nz], xk, i, l);
            pkx = sub2ind([nx ny nz], xk+1, i, l);
            E(3,3,1, ii, pk) = Gz(zk, l)*Gy(yk, i);
            E(3,3,2, ii, pkx) = Gz(zk, l)*Gy(yk, i);
            E(3,4,1, ii, pk) = Gz(zk, l)*Gy(yk+1, i);
            E(3,4,2, ii, pkx) = Gz(zk, l)*Gy(yk+1, i);
            E(4,3,1, ii, pk) = Gz(zk+1, l)*Gy(yk, i);
            E(4,3,2, ii, pkx) = Gz(zk+1, l)*Gy(yk, i);
            E(4,4,1, ii, pk) = Gz(zk+1, l)*Gy(yk+1, i);
            E(4,4,2, ii, pkx) = Gz(zk+1, l)*Gy(yk+1, i);
        end;
    end;    
    for nn=1:nz
        for i=1:ny
            for l=1:nx
                pk = sub2ind([nx ny nz], l, i, nn);
                E(3,3,3, ii, pk) = Gz(zk, nn)* Gy(yk,i) * Gx(xk,l);
                E(3,3,4, ii, pk) = Gz(zk, nn)* Gy(yk,i) * Gx(xk+1,l);
                E(3,4,3, ii, pk) = Gz(zk, nn)* Gy(yk+1,i) * Gx(xk,l);
                E(3,4,4, ii, pk) = Gz(zk, nn)* Gy(yk+1,i) * Gx(xk+1,l);
                E(4,3,3, ii, pk) = Gz(zk+1, nn)* Gy(yk,i) * Gx(xk,l);
                E(4,3,4, ii, pk) = Gz(zk+1, nn)* Gy(yk,i) * Gx(xk+1,l);
                E(4,4,3, ii, pk) = Gz(zk+1, nn)* Gy(yk+1,i) * Gx(xk,l);
                E(4,4,4, ii, pk) = Gz(zk+1, nn)* Gy(yk+1,i) * Gx(xk+1,l);
            end;
        end;
    end;    
    save(fullfile(datafolder, ['E' suffix]), 'E');
end;
% End of function

function f = funSp(x,y,z,xt,yt,zt,a,b,c)

epsilon = 1e-8;
dist = sqrt( (xt-x).^2+(yt-y)^2+(zt-z)^2); 
for i = 1:length(dist)
    if dist(i)<epsilon
        dist(i) = epsilon;
    end;
end;

invdist = 1./dist;
value = ones(1,length(dist));

switch a
    case 1 
        value = value.*(1-z);
    case 2
        value = value.*z;
    case 3 
        value = value.*((1-z)^3-1+z)/6;
    case 4
        value = value.*(z^3-z)/6;
end;
switch b
    case 1 
        value = value.*(1-y);
    case 2
        value = value.*y;
    case 3 
        value = value.*((1-y)^3-1+y)/6;
    case 4
        value = value.*(y^3-y)/6;
end;
switch c
    case 1 
        value = value.*(1-x);
    case 2
        value = value.*x;
    case 3 
        value = value.*((1-x).^3-1+x)/6;
    case 4
        value = value.*(x.^3-x)/6;
end;

f = value.*invdist;