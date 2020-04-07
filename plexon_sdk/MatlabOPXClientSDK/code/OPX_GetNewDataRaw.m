function [ret, data, numblocks] = OPX_GetNewDataRaw(h)

% OPX_GetNewDataRaw - Get data as a single 1D array of doubles, 
% with spikes, continuous data, and digital events all in the 
% same array.  
%
% Inputs:
% - h: handle returned from OPX_InitClient
%
% Outputs:
% - data: array in which data is returned, organized as a series
%   of data blocks, where each block consists of a fixed-length 
%   header followed by zero or more spike waveform points or 
%   continuous data values.  The layout of the header starting at
%   data(i) is given by:
%
%   data(i)   = SourceNumOrType % source number or source type: 
%                               % SPIKE_TYPE (1), EVENT_TYPE (4), or 
%                               % CONTINUOUS_TYPE (5)
%   data(i+1) = Channel         % channel number (source-relative or 
%                               % linear);
%                               % see OPX_SetChannelFormat)
%   data(i+2) = Unit            % unit (0 = unsorted, 1 = a, 2 = b, etc), 
%                               % or strobed event value
%   data(i+3) = TimeStamp                  % timestamp in seconds 
%   data(i+4) = NumberOfBlocksPerWaveform  % for spikes longer than 1 block
%   data(i+5) = BlockNumberForWaveform     % for spikes longer than 1 block
%   data(i+6) = NumberOfDataWords          % number of values in following
%                                          % variable-length segment
%
% If NumberOfDataWords > 0, the variable-length segment begins here:
% 
%   data(i+7) = Points(1) % first of one or more sample values
% 
% Therefore, for a given block of data starting at data(i), the index of
% the SourceNumOrType of the next block is: (i + 7 + data(i+6))
%
% - numblocks: the number of data blocks returned

[ret, data, numblocks] = mexOPXClient(19, h, 0);
