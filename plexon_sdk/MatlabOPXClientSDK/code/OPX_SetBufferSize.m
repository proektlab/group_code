function ret = OPX_SetBufferSize(h, bufSizeMB)

% OPX_SetBufferSize: Sets the size (in megabytes) 
% of the buffer used to transfer data from the 
% OmniPlex Server client datapool.  
%
% Inputs:
% - h: handle returned from OPX_InitClient
% - bufSizeMB: size of the buffer in megabytes
%
% Outputs: 
% - ret: return code; 0 = success, nonzero = error code

[ret] = mexOPXClient(41, h, bufSizeMB);

