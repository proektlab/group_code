function [ret, hWait] = OPX_GetWaitHandle(h)

% OPX_GetWaitHandle - Get a handle to be used when waiting for new data (see OPX_WaitForNewData).
% A client should only call this function once, not every time it calls OPX_WaitForNewData.
%
% Inputs:
% - h: handle returned from OPX_InitClient
%
% Output: 
% - ret: return code; 0 = success, nonzero = error code
% - hWait - wait handle

[ret, hWait] = mexOPXClient(28, h);
