function [ret] = OPX_SendClientDataWords(h, words, numWords)

% OPX_SendClientDataWords: Sends integer data words to Server.  Each call
% may send up to 32 words.  All words in a given call will be given the 
% same hardware timestamp when they are received by Server.  The data words
% will appear in OmniPlex on channel 1 of the "CPX" source, or the equivalent linear
% event channel for multi-bit events (channel 257).
%
% Inputs:
% - h: handle returned from OPX_InitClient
% - words: array of data words to be sent to OmniPlex; data words must be
%   valid 16 bit integer values (-32768 <= x <= +32767)
% - numWords: number of data words to be sent; a maximum of 32 words can be sent 
%   in each call to OPX_SendClientDataWords
% Outputs:
% - ret: return code; 0 = success, nonzero = error code

[ret] = mexOPXClient(48, h, words, numWords);