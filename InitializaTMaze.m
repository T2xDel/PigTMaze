function [] = InitializaTMaze()
%% INITIALIZETMAZE
%
%Written by Timothy Allen, Last Updated: 08/29/2018
%

%% Clear variables and command window
clear
clc

%% Define DIO device and open NI-6501 session
daqreset
DeviceName = daq.getDevices; %defince device name
%daq.getVendors() %use to check vendor and driver versions
s = daq.createSession('ni'); %create session for NI devices

% Define INPUTS as LEFT SIDE of the NI-6501
s.addDigitalChannel(DeviceName(2).ID,'port1/line4:7','InputOnly');
s.addDigitalChannel(DeviceName(2).ID,'port2/line0:7','InputOnly');

% Define OUTPUTS as RIGHT SIDE of the NI-6501
s.addDigitalChannel(DeviceName(2).ID,'port0/line0:7','OutputOnly');
s.addDigitalChannel(DeviceName(2).ID,'port1/line0:3','OutputOnly');

%s.disp; %use to see the NI-6501 map as you set it up

%% Create Door Commands and Cycle the Doors
DoorCommands;
outputSingleScan(s,Doors.OpenAll);
pause(5)
outputSingleScan(s,Doors.CloseAll);
pause(1)
end