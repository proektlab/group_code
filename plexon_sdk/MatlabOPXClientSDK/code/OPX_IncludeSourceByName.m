function ret = OPX_IncludeSourceByName(h, sourceName)

% OPX_IncludeSourceByName: Include the given source in the data sent to this client.  
% Cancels any previous exclusions of the source.
%
% Inputs:
% - h: handle returned from OPX_InitClient
% - sourceName: named of the source to be included
% Outputs:
% - ret: return code; 0 = success, nonzero = error code

ret = mexOPXClient(17, h, sourceName);
