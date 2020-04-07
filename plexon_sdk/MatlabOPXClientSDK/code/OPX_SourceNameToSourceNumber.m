function [ret, sourceNum] = OPX_SourceNameToSourceNumber(h, sourceName)

% OPX_SourceNameToSourceNumber - Convert a source name to the equivalent source number.
%
% Inputs: 
% - h: handle returned from OPX_InitClient
% - sourceName: source name, e.g. "WB"
%
% Outputs:
% - ret: return code; 0 = success, nonzero = error code
% - sourceNum: source number
    
[ret, sourceNum] = mexOPXClient(36, h, sourceName);
