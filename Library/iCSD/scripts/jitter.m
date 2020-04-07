function csdJ = jitter(field_potentials, distance, method, ... 
    VX, VY, VZ, FF)

% JITTER Calculates the inverse CSD using jittering
% see rat_movie for an example of use

% input:
% method: 'step', 'lin', 'splinen' (natural spline),
% 'splinem' (not a knot spline)
% distance: distance between grid points
% field_potentials is a 4-D array of input data
% field_potentials(t,:,:,:) is a 3-D array of values
% of the potential at points (1,1,1), (2,1,1) ... (nx,ny,nz)

% VX, VY, VZ - these vectors define points at which
% the interpolated values are calculated

% FF - two characters, the first is 'J' or 'K' for
% (B) or (D) boundary condition,
% the second is 'B' or 'C' and specifies whether we use
% all jittering vectors ('C') or restrict to a ball ('B').


datafolder = 'data';

if strcmp(method,'step')
    step_method = 1;
else
    step_method = 0;
end;

[nt,nx,ny,nz]=size(field_potentials);
n=nx*ny*nz;
M = (nx+2)*(ny+2)*(nz+2);

CSD = icsd(field_potentials, distance, method, FF);
clear field_potentials;

if step_method&&FF(1)=='K'
    filename = fullfile(datafolder, ['Fd_' ...
        int2str(nx+2) '_' int2str(ny+2) '_' int2str(nz+2) '_' method '.mat']);
else
    filename = fullfile(datafolder, ['Fd_' ...
        int2str(nx) '_' int2str(ny) '_' int2str(nz) '_' method '.mat']);
end;
load(filename, 'displacements');
nr_dp = size(displacements,1);

Fd_use = ones(nr_dp,1);
if FF(2)=='B' 
    rmax = max(max(abs(displacements)));
    for i= 1:nr_dp 
        if (displacements(i,1)^2+displacements(i,2)^2+displacements(i,3)^2)>rmax^2
            Fd_use(i) = 0;
        end;
    end;
end;

if sum(Fd_use)==0
    disp('  ERROR in jitter - no vectors for jittering');
    keyboard
end;

if not(step_method)||FF(1)=='K'
    Flat_CSD = zeros(sum(Fd_use), nt, n);
    for l = 1:nt
        for i = 1:sum(Fd_use)
            for k = 1:n
                Flat_CSD(i,l,k) = CSD(i,l,k);
            end;
        end
    end
    if FF(1)=='J' 
        B = bmatrix(nx,ny,nz);
    end;
    if FF(1)=='K'
        B = bmatrix(nx,ny,nz,'D');
    end;
    Big_Flat_CSD = zeros(sum(Fd_use), nt, M);
    for l = 1:nt
        for i = 1:sum(Fd_use)
            Big_Flat_CSD(i,l,:) = B*squeeze(Flat_CSD(i,l,:));
        end
    end
    Big_CSD = zeros(sum(Fd_use), nt, nx+2, ny+2, nz+2);
    for l=1:nt
        for i = 1:sum(Fd_use)
            for k=1:M
                Big_CSD(i,l,k)=Big_Flat_CSD(i,l,k);
            end;
        end
    end
    clear CSD;
    clear Flat_CSD;
    clear Big_Flat_CSD;
end;

csdJ = zeros(nt, length(VX), length(VY), length(VZ));

if strcmp(method, 'splinen')
    load(fullfile(datafolder, ['E_' ...
        int2str(nx+2) '_' int2str(ny+2) '_' int2str(nz+2) '_splinen.mat']));
    for l = 1:nt
        disp (['  Interp. and averaging CSD, time point ' int2str(l) ' of ' int2str(nt) '...']);
        lk = 1;
        for i = 1:nr_dp
            if Fd_use(i)
                VX2 = VX+1-displacements(i,1);
                VY2 = VY+1-displacements(i,2);
                VZ2 = VZ+1-displacements(i,3); 
                csdJ(l, :, :, :) = squeeze(csdJ(l,:,:,:)) + ...
                    nsplint(squeeze(Big_CSD(lk,l,:,:,:)), ...
                    VX2, VY2, VZ2, E, 'no');
                lk = lk + 1;
            end;
        end;
    end;
elseif step_method&&FF(1)=='J'
    for l = 1:nt
        disp (['  Interp. and averaging CSD, time point ' int2str(l) ' of ' int2str(nt) '...']);
        lk = 1;
        for i = 1:nr_dp
            if Fd_use(i)
                Xvec = (1:nx)+displacements(i,1);
                Yvec = (1:ny)+displacements(i,2);
                Zvec = (1:nz)+displacements(i,3);
                csdJ(l, :, :, :) = squeeze(csdJ(l,:,:,:)) + ...
                    interp3(Yvec,Xvec,Zvec, squeeze(CSD(lk,l,:,:,:)), ...
                    VY', VX, VZ, 'nearest');
                lk = lk + 1;
            end;
        end;
    end;
else
    if strcmp(method, 'lin')
        int3met = 'linear';
    elseif strcmp(method, 'splinem')
        int3met = 'spline';
    else
        int3met = 'nearest';
    end;
    for l = 1:nt
        disp (['  Interp. and averaging CSD, time point ' int2str(l) ' of ' int2str(nt) '...']);
        lk = 1;
        for i = 1:nr_dp
            if Fd_use(i)
                Xvec = (0:nx+1)+displacements(i,1);
                Yvec = (0:ny+1)+displacements(i,2);
                Zvec = (0:nz+1)+displacements(i,3);
                csdJ(l, :, :, :) = squeeze(csdJ(l,:,:,:)) + ...
                    interp3(Yvec,Xvec,Zvec, squeeze(Big_CSD(lk,l,:,:,:)), ...
                    VY', VX, VZ, int3met);
                lk = lk + 1;
            end;
        end;
    end;
end;

csdJ = csdJ/sum(Fd_use);