function ret = OPX_ExcludeSourceByName(h, sourceName)

% OPX_ExcludeSourceByName: Exclude the given source from the data sent to this client.
%
% Inputs:
% - h: handle returned from OPX_InitClient
% - sourceName: name of the source to be excluded
% Outputs: 
% - ret: return code; 0 = success, nonzero = error code

ret = mexOPXClient(14, h, sourceName);
