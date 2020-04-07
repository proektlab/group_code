function ret = OPX_WaitForOPXDAQReady(h, timeout)

% OPX_WaitForOPXDAQReady - Wait for OmniPlex data acquisition to begin, or for a
% specified timeout interval to elapse.  Note that this is not the same as waiting for
% new data to become available, after data acquisition has started.
% 
% Inputs: 
% - h: handle returned from OPX_InitClient
% - timeoutMSecs: timeout interval in milliseconds
%
% Outputs: 
% - ret: return code; 0 = success, nonzero = error code

ret = mexOPXClient(31, h, timeout);
