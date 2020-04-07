function ret = OPX_ExcludeAllSourcesOfType(h, sourceType)

% OPX_ExcludeAllSourcesOfType: Exclude all sources of the given type from the data sent to this client.
%
% Inputs:
% - h: handle returned from OPX_InitClient
% - sourceType: one of SPIKE_TYPE, CONTINUOUS_TYPE, or EVENT_TYPE
% Outputs: 
% - ret: return code; 0 = success, nonzero = error code

ret = mexOPXClient(15, h, sourceType);
