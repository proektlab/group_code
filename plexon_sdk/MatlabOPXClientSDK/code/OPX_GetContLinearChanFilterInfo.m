function [ret, filterInfo] = OPX_GetContLinearChanFilterInfo(h, chan)

% OPX_GetContSourceChanFilterInfoByNumber: Returns the filter information
% for a given continuous channel.
%
% Inputs:
% - h: handle returned from OPX_InitClient
% - chan: continuous channel number
% Outputs:
% - ret: return code; 0 = success, nonzero = error code
% - filterInfo:
% -   filterinfo(1) = 1 if highpass filter is enabled
% -   filterinfo(2) = highpass filter type
% -   filterinfo(3) = highpass filter number of poles
% -   filterinfo(4) = highpass filter frequency
% -   filterinfo(5) = 1 if lowpass filter is enabled
% -   filterinfo(6) = lowpass filter type
% -   filterinfo(7) = lowpass filter number of poles
% -   filterinfo(8) = lowpass filter frequency
% -   filterinfo(9) = 1 if power line interference filter is enabled
% -   filterinfo(10) = power line interference filter frequency
% -   filterinfo(11) = power line interference filter number of harmonics
% -   filterinfo(12) = reserved

[ret, filterInfo] = mexOPXClient(47, h, chan);
