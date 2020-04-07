function [ret, datapoolbytespersec, clientbytespersec] = OPX_GetCurrentBufferRate(h)

% OPX_GetCurrentBufferRate: Returns the current rates of buffer usage (bandwidth).
%
% Inputs:
% - h: handle returned from OPX_InitClient
% Outputs:
% - ret: return code; 0 = success, nonzero = error code
% - datapoolbytespersec: bytes per second being read from Server's client
%   datapool into the buffer whose size is set by OPX_SetBufferSize
% - clientbytespersec: bytes per second being read by this client

[ret, datapoolbytespersec, clientbytespersec] = mexOPXClient(43, h);
