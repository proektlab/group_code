function [ret, OPXstatus] = OPX_GetOPXSystemStatus(h)

% OPX_GetOPXSystemStatus - Get the current state of the OmniPlex system.
%
% Inputs: 
% - h: handle returned from OPX_InitClient
%
% Outputs: 
% - ret: return code; 0 = success, nonzero = error code
% - OPXstatus: current OmniPlex state, one of the values:
%     OPX_DAQ_STOPPED (1): data acquisition is not running
%     OPX_DAQ_STARTED (2): data acquisition is running
%     OPX_RECORDING (3): data acquistion is running and OmniPlex is recording
%     OPX_RECORDING_PAUSED (4): OmniPlex is recording but recording is paused

[ret, OPXstatus] = mexOPXClient(30, h);
