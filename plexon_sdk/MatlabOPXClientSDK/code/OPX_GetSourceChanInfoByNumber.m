function [ret, chanName, rate, enabled] = OPX_GetSourceChanInfoByNumber(h, sourceNum, sourceChan)

% OPX_GetSourceChanInfoByNumber: Given a source number and source-relative channel number,
% returns info for that source channel.
%
% Inputs:
% - h: handle returned from OPX_InitClient
% - sourceNumber: source number
% - sourceChan: source-relative channel number
%
% Outputs: 
% - ret: return code; 0 = success, nonzero = error code
% - chanName: null-terminated string containing the channel name
% - rate: sample rate of the channel (typically the same for all channels in a source)
% - enabled: 1 if channel is enabled, 0 if disabled

[ret, chanName, rate, enabled] = mexOPXClient(10, h, sourceNum, sourceChan);
