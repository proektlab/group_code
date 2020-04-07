function ret = OPX_ExcludeSourceByNumber(h, sourceNum)

% OPX_ExcludeSourceByNumber: Exclude the given source from the data sent to this client.
%
% Inputs:
% - h: handle returned from OPX_InitClient
% - sourceNum: number of the source to be excluded
% Outputs: 
% - ret: return code; 0 = success, nonzero = error code

ret = mexOPXClient(13, h, sourceNum);