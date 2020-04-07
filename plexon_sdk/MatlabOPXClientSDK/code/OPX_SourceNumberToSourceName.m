function [ret, sourceName] = OPX_SourceNumberToSourceName(h, sourceNum)

% OPX_SourceNumberToSourceName - Convert a source number to the equivalent source name.
%
% Inputs:
% - h: handle returned from OPX_InitClient
% - sourceNum: source number
%
% Outputs:
% - ret: return code; 0 = success, nonzero = error code
% - sourceName - string containing the source name 

[ret, sourceName] = mexOPXClient(37, h, sourceNum);
