function [ret, sourceName, sourceType, numChans, linearStartChan] = OPX_GetSourceInfoByNumber(h, sourceNum)

% OPX_GetSourceInfoByNumber: Given a source number, returns basic info about the source.
%
% Inputs: 
% - h: handle returned from OPX_InitClient
% - sourceName: null-terminated string containing the source's name, e.g. "SPKC"
%
% Outputs: 
% - ret: return code; 0 = success, nonzero = error code
% - sourceName: string containing the source name
% - sourceType: one of the values SPIKE_TYPE (1), CONTINUOUS_TYPE (5), EVENT_TYPE (4)
% - numChans: number of channels in the source
% - linearStartChan: starting channel number for the source, within the linear array of channels
%   of the specified type

[ret, sourceName, sourceType, numChans, linearStartChan] = mexOPXClient(4, h, sourceNum);
