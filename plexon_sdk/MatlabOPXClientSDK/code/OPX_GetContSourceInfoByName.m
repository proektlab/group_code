function [ret, sourceNum, rate] = OPX_GetContSourceInfoByName(h, sourceName)

% OPX_GetContSourceInfoByName: Given a continuous source name, returns continuous-source specific info.
%                                                      
% Inputs: 
% - h: handle returned from OPX_InitClient
% - sourceName: string containing the source's name, e.g. "FP"
% Outputs: 
% - ret: return code; 0 = success, nonzero = error code
% - sourceNum: source number 
% - rate: sampling rate in Hz

[ret, sourceNum, rate] = mexOPXClient(9, h, sourceName);