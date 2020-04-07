function ret = OPX_IncludeAllSourcesOfType(h, sourceType)

% OPX_IncludeAllSourcesOfType: Include all sources of the 
% given type in the data sent to this client. Cancels any 
% previous exclusions of the source type.
%
% Inputs:
% - h: handle returned from OPX_InitClient
% - sourceType: one of SPIKE_TYPE (1), CONTINUOUS_TYPE (5), 
%               EVENT_TYPE (4)
% Outputs:
% - ret: return code; 0 = success, nonzero = error code

ret = mexOPXClient(18, h, sourceType);
