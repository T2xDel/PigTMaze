function [AltData] = DelayedAlternation1()
%% DELAYEDALTERNATION1 is right/left alternation with doors moving.
%
%   Trials include a random delay of 5, 240, 60 and 120s. Randomly selected
%   with replacement.
%
%

%Written by Timothy Allen, Last Updated: 09/12/2018
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

%% Alternation Task

%% Get session data
prompt = {'Pig Name','Session Number', 'Date', 'Experimenter',...
    'Number of Trials'};
dlg_title = 'Alt Info';
num_lines = 1;
TodaysDate = datestr(date,1);
def = {'NCLP000','0',TodaysDate,'DelayMaster','50'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

PigName = answer{1};
SessionNumber = answer{2};
SessionDate = answer{3};
Experimenter = answer{4};
numtrials = str2num(answer{5});

DelayTimes = [5; 240; 60; 120]; %Set up the delays as a variable in seconds

%% Pause to make sure the pig is ready (in the Start Area)
disp('*****GET THE PIG READY AND CHECK YOUR SYSTEMS*****');
PigReady = input('Is the pig in the start area?','s');
TrackingReady = input('Is the tracking working well?','s');
disp('If "YES" to both, then go ahead PigMaster. If "NO" then stop.');

%% Set random stream
RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));

%% Set up data sheet
AltData = nan(numtrials,8);
AltData_Headings = {'Trial', 'StartTrialTime','MiddleStemTime',...
    'ChoiceTime','Choice','Accuracy','ReturnTime','DelayTime'};

temp = 1:numtrials;
AltData(:,1) = temp'; %trial number in column one
clear temp

%% Start the clock
tic
zero_time = toc;

for i = 1:numtrials
    
    %Input Map
    %values:    [ 0  0  0  0  0  0  1  1  1  1  1  1]
    %index:     [ 1  2  3  4  5  6  7  8  9 10 11 12]
    %CineLAB:   [H1 H2 H3 H4 H5 H6 L1 L2 L3 L4 L5 L6]
    
    % Open the doors to start the trial
    StartArea = 0;
    if i==1
        fprintf('Trial %d: Waiting for the pig to enter Start Area.\n',i);
    else
        fprintf('Trial %d: Door2 automatically opened after the DelayTime.\n',i);
    end
    while ~StartArea
        [data] = s.inputSingleScan();
        if i==1
            StartArea = data(1); %HT1 = Start Area
        else
            StartArea=1;%Automatically open the door after the DelayTime
        end
        if StartArea==1
            outputSingleScan(s,Doors.StartTrial);
            fprintf('Trial %d: Started.\n',i);
            AltData(i,2) = toc-zero_time; %record start trial time
        end
    end
    
    % Close Door2 when the pig is in the Middle Stem
    MiddleStem = 0;
    fprintf('Trial %d: Waiting for the pig to enter the middle stem area.\n',i);
    while ~MiddleStem
        [data] = s.inputSingleScan();
        MiddleStem = data(2); %HT2 = Middle Stem
        if MiddleStem==1
            outputSingleScan(s,Doors.Close2);
            pause(.1)
            outputSingleScan(s,Doors.Close2);%redundnacy due to triggering issues
            fprintf('Trial %d: The pig entered the middle stem area.\n',i);
            AltData(i,3) = toc-zero_time; %record middle stem entry time
        end
    end
    
    % Let pig make a choice, close the door, reward, return door open
    ChoiceMade = 0;
    fprintf('Trial %d: Waiting for the pig to make a choice.\n',i);
    while ~ChoiceMade
        [data] = s.inputSingleScan();
        LeftChoice = data(4); %HT4 = Left Reward
        RightChoice = data(5); %HT5 = Right Reward
        
        if LeftChoice==1
            outputSingleScan(s,Doors.LeftChoice); pause(.2)
            fprintf('Trial %d: The pig went left.\n',i);
            AltData(i,4) = toc-zero_time; %record choice time
            AltData(i,5) = 4; %4 is left per the door number
            if i==1 %always give reward on the first trial
                outputSingleScan(s,Food.Left); pause(.2);
                outputSingleScan(s,Food.Off);
            elseif i>1
                if AltData(i-1,5)==5 %if last trial was right give reward
                    outputSingleScan(s,Food.Left); pause(.2)
                    outputSingleScan(s,Food.Off);
                    AltData(i,6)=1;
                else %otherwise don't give a reward
                    AltData(i,6)=0;
                end
            end
        end
        
        if RightChoice==1
            outputSingleScan(s,Doors.RightChoice); pause(.2)
            fprintf('Trial %d: The pig went right.\n', i);
            AltData(i,4) = toc-zero_time;
            AltData(i,5) = 5; %4 is left per the door number
            if i==1 %always give reward on the first trial
                outputSingleScan(s,Food.Right); pause(.2)
                outputSingleScan(s,Food.Off);
            elseif i>1
                if AltData(i-1,5)==4 %if the last trial was left give a reward
                    outputSingleScan(s,Food.Right); pause(.2)
                    outputSingleScan(s,Food.Off);
                    AltData(i,6)=1;
                else %otherwise don't give a reward
                    AltData(i,6)=0;
                end
            end
        end
        ChoiceMade = LeftChoice + RightChoice;
        pause(.1)
        outputSingleScan(s,Doors.Close2);
    end
    % Close all doors after a return to start area
    StartArea = 0;
    fprintf('Trial %d: Waiting for the pig to return to the Start Area.\n',i);
    while ~StartArea
        [data] = s.inputSingleScan();
        StartArea = data(1); %HT1
        if StartArea==1
            outputSingleScan(s,Doors.CloseAll);
            fprintf('Trial %d: Ended.\n',i);
            AltData(i,7) = toc-zero_time; %record return time
        end
    end
    
    %% Save the data after each trial
    Command = sprintf('save %s_Session%s.mat',PigName, SessionNumber);
    eval(Command);
    
    if i<numtrials
        temp = randi(4);
        fprintf('Trial %d: Delay for %d seconds.\n',i+1,DelayTimes(temp));
        AltData(i+1,8) = DelayTimes(temp); %record return time
        pause(DelayTimes(temp)) %DelayTime to the next trial
    else
        pause(5) %critical or StartAreaGrating can get stuck on
    end
end

disp('*****CONGRATS! YOUR SESSION IS COMPLETE!!!*****');


