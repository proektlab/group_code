function out = interpolate_csd (csd, VX, VY, VZ, method, boundary)

% INTERPOLATE_CSD Interpolates the CSD 
% This script uses an appropriate method of interpolation
% to reconstruct CSD in the bulk
% Input: csd - 4-D matrix of CSD at the nodes,
% for each t csd(t,:,:,:) is a 3-D matrix of CSD values at points
% (1,1,1), (2,1,1), ... (nx, ny, nz)
% VX, VY, VZ - these vectors define points at which
% the interpolated values are calculated
% method: step, lin, splinen, splinem
% boundary: 'no'='S', 'B', 'D'

[nt,nx,ny,nz] = size(csd);
out = zeros(nt, length(VX), length(VY), length(VZ));
datafolder='data';

if strcmp(method, 'step')
    for l = 1:nt
        out(l,:,:,:) = interp3(squeeze(csd(l,:,:,:)), VY, VX', VZ, 'nearest');
    end;
elseif strcmp(method, 'lin')
    for l = 1:nt
        out(l,:,:,:) = interp3(squeeze(csd(l,:,:,:)), VY, VX', VZ, 'linear');
    end;
elseif strcmp(method, 'splinen')
    switch boundary
        case {'no', 'S'}
            load(fullfile(datafolder,['E_' ...
                int2str(nx) '_' int2str(ny) '_' int2str(nz) '_splinen.mat']));
        case {'B', 'D'}
            load(fullfile(datafolder, ['E_' ...
                int2str(nx+2) '_' int2str(ny+2) '_' int2str(nz+2) '_splinen.mat']));
    end; 
    for l = 1:nt
        out(l,:,:,:) = nsplint(squeeze(csd(l,:,:,:)), VX, VY, VZ, E, boundary);
    end;
elseif strcmp(method, 'splinem')
    switch boundary
        case {'no', 'S'}
            for l = 1:nt
                out(l,:,:,:) = interp3(squeeze(csd(l,:,:,:)),VY, VX', VZ,'spline');
            end;
        case {'B', 'D'}
            if boundary=='B'
                B = bmatrix(nx, ny, nz);
            end;
            if boundary=='D'
                B = bmatrix(nx, ny, nz, 'D');
            end;
            for l = 1:nt
                out(l,:,:,:) = interp3(0:ny+1, 0:nx+1, 0:nz+1, ...
                reshape(B*csd(l,:)',nx+2,ny+2,nz+2), ...
                VY, VX', VZ, 'spline');
            end;
    end;
end;