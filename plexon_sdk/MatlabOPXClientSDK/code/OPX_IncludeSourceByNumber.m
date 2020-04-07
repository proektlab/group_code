function ret = OPX_IncludeSourceByNumber(h, sourceNum)

% OPX_IncludeSourceByNumber: Include the given source in the data sent to this client.  
% Cancels any previous exclusions of the source.
%
% Inputs:
% - h: handle returned from OPX_InitClient
% - sourceNum: number of the source to be included
%
% Outputs: 
% - ret: return code; 0 = success, nonzero = error code

ret = mexOPXClient(16, h, sourceNum);
