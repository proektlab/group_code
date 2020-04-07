function [ret, data, numblocks] = OPX_GetNewTimestampsRaw(h)

% OPX_GetNewTimestampsRaw - Get data as a single 1D array of 
% doubles, with spikes and digital events all intermixed in 
% the same array.  This function is similar to OPX_GetNewDatRaw 
% except that no spike waveform points or continuous data are
% returned.
%
% Inputs:
% - h: handle returned from OPX_InitClient
%
% Outputs:
% - data: array in which data is returned, organized as a series
%   of data blocks, where each block is a fixed length.  The 
%   layout of the block starting at data(i) is given by:
%
%   data(i)   = SourceNumOrType % source number or source type: 
%                               % SPIKE_TYPE (1) or EVENT_TYPE (4)
%   data(i+1) = Channel         % channel number (source-relative or 
%                               % linear);
%                               % see OPX_SetChannelFormat)
%   data(i+2) = Unit            % unit (0 = unsorted, 1 = a, 2 = b, etc)
%                               % or strobed event value
%   data(i+3) = TimeStamp       % timestamp in seconds 
% 
% Therefore, for a given block of data starting at data(i), the index 
% of the SourceNumOrType of the next block is (i + 4)
%
% - numblocks: the number of data blocks returned

[ret, data, numblocks] = mexOPXClient(19, h, 1);