function [ret, chanName, rate, enabled] = OPX_GetLinearChanInfo(h, linearChanType, chan)

% OPX_GetLinearChanInfo: Given a channel type and channel number within that type,
% returns info for that channel.
%
% Inputs:
% - h: handle returned from OPX_InitClient
% - linearChanType: channel type, one of:
%   SPIKE_TYPE  = 1, 
%   EVENT_TYPE = 4,
%   CONTINUOUS_TYPE = 5
% - chan: channel number within one of the channel types
%
% Outputs:
% - ret: return code; 0 = success, nonzero = error code
% - chanName: string containing the channel name
% - rate: sample rate of the channel (typically the same for all channels in a source)
% - enabled: 1 if channel is enabled, 0 if disabled
    
[ret, chanName, rate, enabled] = mexOPXClient(12, h, linearChanType, chan);
