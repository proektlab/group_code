function [ret, t] = OPX_GetLocalMachineTime(h)

% OPX_GetLocalMachineTime - Returns the current machine time (Windows time).  Note that machine time 
% is not the same as acquisition time ("timestamp time").
%
% Inputs: 
% - h: handle returned from OPX_InitClient
%
% Outputs: 
% - ret: return code; 0 = success, nonzero = error code
% - t: current machine time
    
[ret, t] = mexOPXClient(35, h);
