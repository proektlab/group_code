function ret = OPX_ClearData(h, timeoutMSecs)

% OPX_ClearData - Reads and discards client data, until no more data is immediately 
% available, or until a specified timeout interval elapses.  This is useful when a client
% needs to avoid processing a potentially large "backlog" of data, for example, at startup 
% or if it desires to only occasionally read a "sample" of the incoming data.
%
% Inputs: 
% - h: handle returned from OPX_InitClient
% - timeoutMSecs: timeout interval in milliseconds
% Outputs: 
% - ret: return code; 0 = success, nonzero = error code

ret = mexOPXClient(32, h, timeoutMSecs);