function [ret, linearChanType, linearChan] = OPX_SourceChanToLinearChanAndType(h, sourceNum, sourceChan)

% OPX_SourceChanToLinearChanAndType - Convert a source number and source-relative channel number to
% a source type and a channel number within one of the linear channel number ranges.
%
% Inputs:
% - h: handle returned from OPX_InitClient
% - sourceNum - source number
% - sourceChan - channel number within the specified source
%
% Outputs:
% - ret: return code; 0 = success, nonzero = error code
% - linearChanType - channel type: SPIKE_TYPE (1), CONTINUOUS_TYPE (5), or
%   EVENT_TYPE (4)
% - linearChan - channel number within the channel range of the returned channel type

[ret, linearChanType, linearChan] = mexOPXClient(38, h, sourceNum, sourceChan);

