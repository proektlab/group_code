function CSD = icsd (field_potentials, distance, method, boundary)

% ICSD Calculates CSD using inverse method
% This script uses an appropriate invF matrix loaded
% from file F_nx_ny_nz_method.mat
% input: 
% boundary: 'no' 'B' 'D' 'JB' 'JC' 'KB' 'KC'
% method: 'step', 'lin', 'splinen' (natural spline),
% 'splinem' (not a knot spline)
% distance: distance between grid points
% field_potentials is a 4-D array of input data
% field_potentials(t,:,:,:) is a 3-D array of values
% of the potential at points (1,1,1), (2,1,1) ... (nx,ny,nz)
%
% Output: 4-D array of CSD values at the grid points
% If boundary is 'J...' or 'K...' then the returned 
% array is 5-D, the first index numbers the vectors used for jittering

[nt,nx,ny,nz]=size(field_potentials);
n=nx*ny*nz;

datafolder = 'data';

if strcmp(method,'step')
    step_method = 1;
else
    step_method = 0;
end;

if step_method&&(boundary(1)=='B')
    disp('Warning in iCSD: "B" boundary conditions not supported');
    disp('for step method. Switching to "no".');
    boundary = 'no';
end;

switch boundary(1)
    case 'n'
        CSD = zeros(size(field_potentials));
        filename = fullfile(datafolder, ['F_' ...
            int2str(nx) '_' int2str(ny) '_' int2str(nz) '_' method '.mat']);
        load (filename);
        invF = invF/distance^2;
        CSD = FTimesData(field_potentials, invF, nt, n);
    case 'B'
        CSD = zeros(size(field_potentials));
        filename = fullfile(datafolder, ['F_' ...
            int2str(nx+2) '_' int2str(ny+2) '_' int2str(nz+2) '_' method '.mat']);
        load(filename);
        B = bmatrix(nx,ny,nz);
        R = rmatrix(nx,ny,nz);
        invF = inv(R*inv(invF)*B)/distance^2;
        CSD = FTimesData(field_potentials, invF, nt, n);
    case 'D'
        CSD = zeros(size(field_potentials));
        filename = fullfile(datafolder, ['F_' ...
            int2str(nx+2) '_' int2str(ny+2) '_' int2str(nz+2) '_' method '.mat']);
        load(filename);
        B = bmatrix(nx,ny,nz,'D');
        R = rmatrix(nx,ny,nz);
        invF = inv(R*inv(invF)*B)/distance^2;
        CSD = FTimesData(field_potentials, invF, nt, n);
    case {'J', 'K'}
        if not(step_method)||boundary(1)=='K'                
            if boundary(1)=='J'                
                B = bmatrix(nx,ny,nz);
            else
                B = bmatrix(nx,ny,nz,'D');
            end;
            R = rmatrix(nx,ny,nz);
        end;
        if step_method&&boundary(1)=='K'                
            filename = fullfile(datafolder, ['Fd_' ...
                int2str(nx+2) '_' int2str(ny+2) '_' int2str(nz+2) '_' method '.mat']);
        else
            filename = fullfile(datafolder, ['Fd_' ...
                int2str(nx) '_' int2str(ny) '_' int2str(nz) '_' method '.mat']);
        end;
        load(filename);
        nr_dp = size(Fd,1);      
        Fd_use = ones(nr_dp,1);
        if boundary(2)=='B'
            rmax = max(max(abs(displacements)));
            for i= 1:nr_dp
                if (displacements(i,1)^2+displacements(i,2)^2+displacements(i,3)^2)>rmax^2
                    Fd_use(i) = 0;
                end;
            end;
        end;
        if sum(Fd_use)==0
            disp('  ERROR:  in iCSD - no vectors for jittering');
            keyboard
        end;
        disp(['  Using ' int2str(sum(Fd_use)) ' vectors for jittering...']);
        CSD = zeros(sum(Fd_use),nt,nx,ny,nz);
        lk = 1;
        for i = 1:nr_dp
            if Fd_use(i)
                if step_method&&boundary(1)=='J' 
                    CSD(lk, :,:,:,:)=FTimesData(field_potentials, ...
                        inv(squeeze(Fd(lk,:,:)))/distance^2, nt, n);
                else 
                    CSD(lk, :,:,:,:)=FTimesData(field_potentials, ...
                        inv(R*squeeze(Fd(lk,:,:))*B)/distance^2, nt, n);
                end;
                lk = lk + 1;
            end;
        end;
end;

function out = FTimesData(fpot, invF, nt, n)
FlatData=zeros(nt,n);     
out = zeros(size(fpot));
for k=1:n
    FlatData(:,k)=fpot(:,k);
end
temp = zeros(nt,n);
for k=1:nt
    temp(k,:)=invF*squeeze(FlatData(k,:)');   
end
for l=1:nt          
    for k=1:n 
        out(l,k)=temp(l,k);
    end
end
