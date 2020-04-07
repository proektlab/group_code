function [ret, t] = OPX_GetLastWaitEventTime(h)

% OPX_GetLastWaitEventTime - Get the machine time (Windows time) when new client data was most 
% recently available.  Clients can use this function to determine whether new client data was made
% available since the previous time they called the function.  However, for lowest latency, clients
% should use the OPX_WaitForNewData function.  Note that machine time is not the same as acquisition 
% time ("timestamp time").
%
% Inputs: 
% - h: handle returned from OPX_InitClient
%
% Output: 
% - t: time when new client data was most recently made available, i.e. when clients who were waiting 
%      on OPX_WaitForNewData were allowed to continue execution.

[ret, t] = mexOPXClient(34, h);
