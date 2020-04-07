function h = OPX_InitClient(dataformat);

% OPX_InitClient: Must be called before any other OPX_* client function,
% and only once per client.  Performs one-time initialization and sets the
% format for channel numbering for returned spike, continuous, and event data.
%
% Inputs:
% - dataformat:
%
%   dataformat == 1 : calls to OPX_GetNew* functions will return data with
%   linear channel numbers (1..n for each source type (spike, event, continuous))
%
%   dataformat == 2 : calls to OPX_GetNew* will return data with
%   source-relative channel numbers (1..n for each source)
%
% Outputs:
% - h: client instance handle, which must be passed as the first parameter
%   to all subsequent OPX_* functions; if h < 0, the value is an error code
%   indicating that the client could not be initialized

h = mexOPXClient(1, dataformat);
