function [ret, linearChanType, linearChan] = OPX_SourceNameChanToLinearChanAndType(h, sourceName, sourceChan)

% OPX_SourceNameChanToLinearChanAndTypeByName - Convert a source-name
% relative channel number to the corresponding linear channel type and
% channel-type relative channel number.
%
% Inputs:
% - h: handle returned from OPX_InitClient
% - sourceName: source name
% - sourceChan: channel number within the specified source
%
% Outputs:
% - ret: return code; 0 = success, nonzero = error code
% - linearChanType: channel type: SPIKE_TYPE (1), CONTINUOUS_TYPE (5), or
%   EVENT_TYPE (4)
% - linearChan: channel number within the channel range of the returned channel type

[ret, linearChanType, linearChan] = mexOPXClient(39, h, sourceName, sourceChan);
