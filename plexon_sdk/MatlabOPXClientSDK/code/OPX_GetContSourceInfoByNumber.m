function [ret, sourceName, rate] = OPX_GetContSourceInfoByNumber(h, sourceNum)

% OPX_GetContSourceInfoByNumber: Given a continuous source, returns continuous-source specific info.
%                                                      
% Inputs: 
% - h: handle returned from OPX_InitClient
% - sourceNum: number of the continuous source whose info is being requested
% Outputs:
% - ret: return code; 0 = success, nonzero = error code
% - sourceNum: source number 
% - rate: sampling rate in Hz

[ret, sourceName, rate] = mexOPXClient(8, h, sourceNum);
