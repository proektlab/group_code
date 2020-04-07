%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   (c) 1999-2018 Plexon Inc. Dallas Texas 75206 USA
%   www.plexon.com / support@plexon.com
%
%   This code is provided for users of Plexon products. If you copy, disseminate, reproduce,
%   post or archive this code, please do not remove or alter this notice or the copyright above.
%   All sample code and libraries are provided as-is and Plexon cannot be responsible for errors 
%   or consequential damage caused by its use, including user code derived from or based on this code.  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OPXErrorCodes.m
%
%  This is not an executable sample client program, but rather a list of standard values that are 
%  passed to or returned from client API functions.  You can include this code in any client as needed.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Formats for client data channel numbers
%
% Channel numbers are relative to one of the four channel types
OPX_CHANNEL_FORMAT_LINEAR = 1;
% Channel numbers are relative to the channel's source
OPX_CHANNEL_FORMAT_SOURCE_RELATIVE = 2;

% The three source types for OPX_CHANNEL_FORMAT_LINEAR
SPIKE_TYPE = 1; 
EVENT_TYPE = 4;
CONTINUOUS_TYPE = 5;

% Values for systemType parameter returned by OPX_GetGlobalParameters.
%
% Indicates that no valid topology is loaded in Server
OPXSYSTEM_INVALID = 0;
%
% OmniPlex system using a TestADC (data file playback "device")
OPXSYSTEM_TESTADC = 1;
%
% OmniPlex-A system
OPXSYSTEM_AD64 = 2;
%
% OmniPlex-D system, using either DigiAmp or MiniDigi
OPXSYSTEM_DIGIAMP = 4;
%
% OmniPlex-D system, using Digital Headstage Processor (DHP)
OPXSYSTEM_DHSDIGIAMP = 8;

% Values returned by OPX_GetOPXSystemStatus
%
% data acquisition stopped
OPX_DAQ_STOPPED = 1;
% data acquisition started (running)
OPX_DAQ_STARTED = 2;
% data file = pl2/plx; being recorded
OPX_RECORDING = 3;
% data file being recorded, but paused
OPX_RECORDING_PAUSED = 4;

%
% Error codes returned by API functions
%

% No error.
OPX_ERROR_NOERROR = 0;

% One of the client datapools that OmniPlex uses to communicate with clients 
% was not found.  Check to make sure that OmniPlex Server is running.
OPX_ERROR_NODATAPOOL1 = -1;
OPX_ERROR_NODATAPOOL2 = -2;

% An attempt to allocate memory failed.
OPX_ERROR_NOMEM = -3;

% A bad channel type / source type was passed to an API function.  Valid types are
% SPIKE_TYPE, CONTINUOUS_TYPE, EVENT_TYPE, and OTHER_TYPE.
OPX_ERROR_BADCHANTYPE = -4;

% An invalid source number was passed to an API function.  Make sure that you are 
% passing a source number obtained by a call to OPX_GetGlobalParameters.  Note that
% source numbers do not necessarily start at 1 or form a contiguous range of 
% source numbers.
OPX_ERROR_BADSOURCENUM = -5;

% An invalid source-relative channel number was passed to an API function.  
% Valid channel numbers are in the range 1..NumberOfChansForSource
OPX_ERROR_BADSOURCECHAN = -6;

% An invalid linear channel number was passed to an API function.  
% Valid linear channel numbers start at 0 for channels of CONTINUOUS_TYPE
% and start at 1 for all other channel types.
OPX_ERROR_BADLINEARCHAN = -7;

% An invalid data format was passed to an API function.  Valid formats are 
% CHANNEL_FORMAT_LINEAR and CHANNEL_FORMAT_SOURCE_RELATIVE.
OPX_ERROR_BADDATAFORMAT = -8;

% A null (zero) parameter was passed to an API function which does not allow a
% null value for that parameter.
OPX_ERROR_NULLPARAMETER = -9;

% The requested mapping, for example, between a source name and a source number, 
% could not be performed, possibly because one or more parameters were invalid.
OPX_ERROR_MAPPINGFAILED = -10;

% The client failed to initialize.  Either OPX_InitClient was not called before
% any other client API function, or it was called but returned an error code.  
% Attempts to call API functions after a failed initialization will return this error.
OPX_INIT_FAILED = -11;

% The wait handle could not be opened.  Make sure that OmniPlex Server is running.
OPX_ERROR_NOWAITHANDLE = -12;

% The specified timeout interval elapsed/expired.
OPX_ERROR_TIMEOUT = -13;

% OPX_ClearData returned before it was able to clear all the available data.
OPX_ERROR_NOTCLEARED = -14;

% OPX_SendClientDataWords was unable to open the CinePlex device client, which is
% used for sending data words to Server
OPX_ERROR_OPEN_DLL_FAILED = -15;

% The available data was larger than the return buffer.  The caller should call
% the OPX_Get* function again to get more of the available data.
OPX_ERROR_NOT_ALL_DATA_WAS_RETURNED = -16;

