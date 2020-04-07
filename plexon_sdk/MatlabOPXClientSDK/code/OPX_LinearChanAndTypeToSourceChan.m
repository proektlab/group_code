function [ret, sourceName, sourceNum, sourceChan] = OPX_LinearChanAndTypeToSourceChan(h, linearChanType, linearChan)

% OPX_LinearChanAndTypeToSourceChan - Convert a channel type and channel number within that channel 
% type's channel range into the equivalent source number, source name, and source-relative channel.
%
% Inputs: 
% - h: handle returned from OPX_InitClient
% - linearChanType - channel type: SPIKE_TYPE (1), CONTINUOUS_TYPE (5), or EVENT_TYPE (4)
% - linearChan - 1-based channel number within the channel range of the specified channel type
%
% Outputs:
% - ret: return code; 0 = success, nonzero = error code
% - sourceNum - source number
% - sourceName - source name
% - sourceChan - source-relative channel number

[ret, sourceName, sourceNum, sourceChan] = mexOPXClient(40, h, linearChanType, linearChan);
