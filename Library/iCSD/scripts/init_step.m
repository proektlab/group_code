function init_step(nx,ny,nz)

% Calculates the F matrix for step approximation

datafolder = 'data';
rmax = 0.5; % Maximal displacement in jittering
n = nx*ny*nz;

if not(exist(fullfile(datafolder, ['F_' ...
        int2str(nx) '_' int2str(ny) '_' int2str(nz) '_step.mat']), 'file'))
    disp(' Generating invF for stepwise distribution...');
    F = FdMatrix(nx,ny,nz,[0 0 0]); 
    invF=inv(F); 
    save(fullfile(datafolder, ['F_' ...
        int2str(nx) '_' int2str(ny) '_' int2str(nz) '_step.mat']), 'invF');
else
    disp(' Generating invF for stepwise distribution with jittering...');
    filename = fullfile(datafolder, ['Fd_' int2str(nx) '_' int2str(ny) '_' int2str(nz) '_step.mat']);

    rand('state', sum(100*clock));
    displ_l = zeros(1,3); 
    z = rand*2*rmax-rmax;
    y = rand*2*rmax-rmax;
    x = rand*2*rmax-rmax;
    displ_l(1,3) = z;
    displ_l(1,1) = x;
    displ_l(1,2) = y;
    
    F=zeros(1,n,n);
    F(1,:,:) = FdMatrix(nx,ny,nz,displ_l); 

    if exist(filename, 'file')
        load(filename);
        Fd = cat(1,Fd,F);
        displacements = cat(1,displacements, displ_l);
    else
        Fd = F;
        displacements = displ_l;
    end;
    save(filename, 'Fd', 'displacements');
end;

function Fd=FdMatrix (nx,ny,nz, dsp)


n = nx*ny*nz; 
dspx = dsp(1,1);
dspy = dsp(1,2);
dspz = dsp(1,3);

Fd = zeros(n); 

F_temp = zeros(2*nx-1,2*ny-1, 2*nz-1);

meter_1 = (2*nx-1)*(2*ny-1)*(2*nz-1);
counter_1 = 0;

for xp=1:2*nx-1
    for yp=1:2*ny-1
        for zp=1:2*nz-1
            xt = xp - nx;
            yt = yp - ny;
            zt = zp - nz;
            F_temp(xp,yp,zp) = 1/4/pi*triplequad(@(x,y,z) ...
                fun_invdist(x,y,z,xt-dspx,yt-dspy,zt-dspz), ...
                -0.5,0.5,-0.5,0.5,-0.5,0.5);
            counter_1 = counter_1 + 1;
            disp([int2str(counter_1) ' of ' int2str(meter_1) ' done']);
        end;
    end;
end;

for j=1:n 
    for i=1:n 
        [xi,yi,zi] = ind2sub ([nx,ny,nz],i); 
        [xj,yj,zj] = ind2sub([nx,ny,nz],j); 
        Fd(i,j) = F_temp(xi-xj+nx, yi-yj+ny, zi-zj+nz);
    end;
end;
%%% End of function 

function invdist = fun_invdist(x,y,z,xt,yt,zt) 
epsilon = 1e-8;
dist = sqrt( (xt-x).^2+(yt-y)^2+(zt-z)^2); 
for i = 1:length(dist)
    if dist(i)<epsilon
        dist(i) = epsilon;
    end;
end;
invdist = 1./dist;
