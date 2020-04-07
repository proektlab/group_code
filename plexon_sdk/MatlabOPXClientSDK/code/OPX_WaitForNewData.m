function [ret] = OPX_WaitForNewData(h, hWait, timeout)

% OPX_WaitForNewData - Wait for new client data.  
% The client will block (wait) without using CPU time 
% until either new data is available, or the specified 
% timeout elapses.
% 
% Inputs: 
% - h: handle returned from OPX_InitClient
% - hWait - wait handle (see OPX_GetWaitHandle)
% - timeoutMSecs - timeout interval in milliseconds
%
% Outputs:
% - ret: return code; 0 = success, nonzero = error code

[ret] = mexOPXClient(29, h, hWait, timeout);
