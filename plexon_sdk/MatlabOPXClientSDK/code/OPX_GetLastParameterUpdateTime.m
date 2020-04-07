function [ret, t] = OPX_GetLastParameterUpdateTime(h)

% OPX_GetLastParameterUpdateTime - Get the machine time (Windows time) when any client-accessible 
% OmniPlex parameter was updated.  Clients can use this function to determine whether a  
% parameter has changed since the previous time they called the function.  Note that machine time
% is not the same as acquisition time ("timestamp time").
%
% Inputs: 
% - h: handle returned from OPX_InitClient
% Outputs: 
% - ret: return code; 0 = success, nonzero = error code
% - t: time of the most recent parameter update 
    
[ret, t] = mexOPXClient(33, h);
