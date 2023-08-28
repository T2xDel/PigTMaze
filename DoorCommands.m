%% DOORCOMMANDS sets up a structure with basic door commands.
% For use with the PNF TMaze in OE138
%
%Written by Timothy Allen, Last updated: 08/29/2018
%
%Index: [Open1 Open2 Open3 Open4 Open5 PelletLeft PelletRight Close1 Close2 Close3 Close4 Close5];
%

%% Basic Door Commands
%
Doors.Open1 = [1 0 0 0 0 0 0 0 0 0 0 0];
Doors.Open2 = [0 1 0 0 0 0 0 0 0 0 0 0];
Doors.Open3 = [0 0 1 0 0 0 0 0 0 0 0 0];
Doors.Open4 = [0 0 0 1 0 0 0 0 0 0 0 0];
Doors.Open5 = [0 0 0 0 1 0 0 0 0 0 0 0];

Doors.Close1 = [0 0 0 0 0 0 0 1 0 0 0 0];
Doors.Close2 = [0 0 0 0 0 0 0 0 1 0 0 0];
Doors.Close3 = [0 0 0 0 0 0 0 0 0 1 0 0];
Doors.Close4 = [0 0 0 0 0 0 0 0 0 0 1 0];
Doors.Close5 = [0 0 0 0 0 0 0 0 0 0 0 1];

%% Compound Door Commands
Doors.StartTrial = [0 1 0 1 1 0 0 0 0 0 0 0];
Doors.ForceLeft = [0 1 0 1 0 0 0 0 0 0 0 0];
Doors.ForceRight = [0 1 0 0 1 0 0 0 0 0 0 0];
Doors.RightChoice = [0 0 1 0 0 0 0 1 1 0 1 1];
Doors.LeftChoice = [1 0 0 0 0 0 0 0 1 1 1 1];
Doors.OpenAll = [1 1 1 1 1 0 0 0 0 0 0 0];
Doors.CloseAll = [0 0 0 0 0 0 0 1 1 1 1 1];

%% Food Pellet Dispensor Commands

Food.Left = [0 0 0 0 0 1 0 0 0 0 0 0];
Food.Right = [0 0 0 0 0 0 1 0 0 0 0 0];
Food.Off = [0 0 0 0 0 0 0 0 0 0 0 0];
