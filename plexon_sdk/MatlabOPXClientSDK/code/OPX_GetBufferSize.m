function [ret, bufSizeMB] = OPX_GetBufferSize(h)

% OPX_GetBufferSize: Returns the size (in megabytes) of the buffer used
% to transfer data from the OmniPlex Server client datapool.  
%
% Inputs:
% - h: handle returned from OPX_InitClient
%
% Outputs: 
% - ret: return code; 0 = success, nonzero = error code
% - bufSizeMB: current size of the buffer, in megabytes

[ret, bufSizeMB] = mexOPXClient(42, h);
