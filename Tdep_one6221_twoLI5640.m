function T_sweep(nF,DRL,DRNL ) 
% nF = what harmonic to lock-in 
% Curr & Freq = input current 
% DR = 0 (high), 1 (medium), 2 (low)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Parameter setting %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clear command window
clc;
% clear figure window
close all;
%delete all instruments' ports
delete(instrfind);


% Delta mode param
%Set Delta mode I max [A]
%Param.Imax = [1.5e-3,1.342e-3,1.162e-3,0.9487e-3,0.67e-3];%[0.67e-3,0.9487e-3,1.162e-3,1.342e-3,1.5e-3]%1.5e-3%0.67e-3;%0.3e-3;          
Param.Imax = 100.0e-6;
Param.VComp = 50;
Param.Ifrequency=13.7;

% Trim% precent extrem value exclude
Param.Trim =50;

Param.GPIB6221C1 = 2;
%Param.GPIB6221C2 = 11;
Param.GPIB5640L = 6;
Param.GPIB5640NL = 5;

%Parameter for PPMS
Param.InitialTemp=300;
Param.InitialTempRate=3;
Param.time_wait_InitialT = 60;
Param.Temp=[300,270,240,210,180,150];
%Param.Temp=[2];
Param.TempRate=1;                                                          %Set the Rate to change temperature
Param.Tempnum=length(Param.Temp);                                          %Count the number of listed items
Param.time_wait_T = 5;                                                   %wait time for each measurement to settle (s)
%Param.Tc = 10.10;
%Param.TempFinal = 10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initializing the instruments %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % No 1, Instrument:
% Keithley 6221 AC Source set sine mode,

[Sta,Instrs.K6221C1] = F_6221(0,Param.GPIB6221C1); % Initializing 6221
Sta = F_6221(3,Instrs.K6221C1,1e-9,Param.Ifrequency(1),Param.VComp); % set 1nA current Sin wave to 6221;
Sta = F_6221(98,Instrs.K6221C1); % begin output;

%[Sta,Instrs.K6221C2] = F_6221(0,Param.GPIB6221C2); % Initializing 6221
%Sta = F_6221(3,Instrs.K6221C2,1e-9,Param.Ifrequency(1),Param.VComp); % set 1nA current Sin wave to 6221;
%Sta = F_6221(98,Instrs.K6221C2); % begin output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%No 2, LockIn
% Result=fscanf(Instrs.LI5640)   % quirery

nFL=1
nFNL=2

DRL=2
DRNL=2
% SENSITIVITY = 0-26 (numerical)
%0-2nV;1-5nV;2-10nV;3-20nV;4-50nV;5-100nV;6-200nV;7-500nV;8-1uV;9-2uV;10-5uV;11-10uV;12-20uV;13-50uV;14-100uV;15-200uV;16-500uV;17-1mV;18-2mV;19-5mV;20-10mV;21-20mV;22-50mV;23-100mV;24-200mV;25-500mV;
VSensL=15
VSensNL=8

[Sta,Instrs.LI5640L]=F_LI5640(0,Param.GPIB5640L,nFL,VSensL,DRL); %7:500nV   12:20uV range
[Sta,Instrs.LI5640NL]=F_LI5640(0,Param.GPIB5640NL,nFNL,VSensNL,DRNL); %7:500nV   12:20uV range

% data file param
%Param.folder = ['CernoxTop11-12&Bottom9-10_RT'];
Param.folder = ['magnetite4_crossnonlinear'];

switch DRL
    case 0
        HogeL = 'Hi'
    case 1
        HogeL = 'Med'
    case 2
        HogeL = 'Lo'
end


switch DRNL
    case 0
        HogeNL = 'Hi'
    case 1
        HogeNL = 'Med'
    case 2
        HogeNL = 'Lo'
end

Param.fileHeader = ['_',num2str(nFL),'f_',HogeL,'_VSens',num2str(VSensL),'_',num2str(nFNL),'f_',HogeNL,'_VSens',num2str(VSensNL),'_Imax',num2str(Param.Imax),'_'];                                                      %file path


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%No 3, PPMS
InstQD=ConQDInstru; % connect to the Dynacool or PPMS


Path=fullfile(pwd,'QDInstrument.dll');
QDdll = NET.addAssembly(Path);
import QuantumDesign.QDInstrument.*;
import QuantumDesign.QDInstrument.QDInstrumentFactory.*;
import QuantumDesign.QDInstrument.QDInstrumentBase.*;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Measurement loop          %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mkdir(Param.folder);

for currIndex=1:length(Param.Imax)

    for freqIndex = 1:length(Param.Ifrequency)

        % abort I current;
        Sta = F_6221(99,Instrs.K6221C1) ;
        %Sta = F_6221(99,Instrs.K6221C2) ;
        pause(1);
        % set current Sin wave to 6221;
        Sta = F_6221(3,Instrs.K6221C1,Param.Imax(currIndex),Param.Ifrequency(freqIndex),Param.VComp) ;
        %Sta = F_6221(3,Instrs.K6221C2,Param.Imax(currIndex),Param.Ifrequency(freqIndex),Param.VComp) ;
        % begin output;
        Sta = F_6221(98,Instrs.K6221C1) ;
        %Sta = F_6221(98,Instrs.K6221C2) ;
        %pause(60)
        for tempIndex=1:Param.Tempnum
             Sta=SetTemper(InstQD,Param.InitialTemp,Param.InitialTempRate,1);
             Sta=WaitTempStable(InstQD);
             pause(Param.time_wait_InitialT);

            
             data.T = []; data.VxL = []; data.VyL=[];  data.VxNL = []; data.VyNL=[]; data.time=[]; m=1;
             data.VxLStd = []; data.VyLStd=[];data.VxNLStd = []; data.VyNLStd=[];
                
             time=datetime('now','Format','yyyy-MMdd-HHmm');
            %set waiting time before measurement
             Sta=SetTemper(InstQD,Param.Temp(tempIndex),Param.TempRate,1);
             tic;
             TempStatus = 'Chasing';
             while strcmp(TempStatus,'Stable')~=1 %%%Œp‘±ðŒ
                [m,data,TempStatus]=SweepTempMeasure(InstQD,Param,Instrs,tempIndex,currIndex,freqIndex,time,m,data);
                pause(Param.time_wait_T)
             end
             
             Sta=WaitTempStable(InstQD);
             pause(1);

        end
            
            close all;
            
            %delete the variable in which data is saved for plotting
            clear data;
            
    end
end
 


% abort I current;
Sta = F_6221(99,Instrs.K6221C1) ;
fclose(Instrs.K6221C1);
%Sta = F_6221(99,Instrs.K6221C2) ;
%fclose(Instrs.K6221C2);

%clear all parameters
clear all;
%clear command window
clc;
delete(instrfind);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  sweep field and measure FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [m,data,TempStatus]=SweepTempMeasure(InstQD,Param,Instrs,TempIndex,CurrentIndex,FreqIndex,time,m,data)
%m: var for magnetic field plot and record
%H: list for field data
%data0: list for resist data

Path=fullfile(pwd,'QDInstrument.dll');
QDdll = NET.addAssembly(Path);
import QuantumDesign.QDInstrument.*;
import QuantumDesign.QDInstrument.QDInstrumentFactory.*;
import QuantumDesign.QDInstrument.QDInstrumentBase.*;


%try
    
    [Sta,ResultL] = F_LI5640(1,Instrs.LI5640L);
    data.VyL = [data.VyL,ResultL(2)];
    data.VxL = [data.VxL,ResultL(1)];
    
    
    [Sta,ResultNL] = F_LI5640(1,Instrs.LI5640NL);
    data.VyNL = [data.VyNL,ResultNL(2)];
    data.VxNL = [data.VxNL,ResultNL(1)];
    

%end


% remove extrem value
% try
%  
%     data.VxLtemp=sort(data.VxLtemp);
%     data.VxLtemp(1:round(Param.Trim/200*length(data.VxLtemp))  )=100;
%     data.VxLtemp(round( (1-Param.Trim/200)*length(data.VxLtemp)) :end )=100;
%     data.VxLtemp(data.VxLtemp>1)=[];
%     
%     data.VyLtemp=sort(data.VyLtemp);
%     data.VyLtemp(1:round(Param.Trim/200*length(data.VyLtemp))  )=100;
%     data.VyLtemp(round( (1-Param.Trim/200)*length(data.VyLtemp)) :end )=100;
%     data.VyLtemp(data.VyLtemp>1)=[];
% 
%     data.VxNLtemp=sort(data.VxNLtemp);
%     data.VxNLtemp(1:round(Param.Trim/200*length(data.VxNLtemp))  )=100;
%     data.VxNLtemp(round( (1-Param.Trim/200)*length(data.VxNLtemp)) :end )=100;
%     data.VxNLtemp(data.VxNLtemp>1)=[];
%     
%     data.VyNLtemp=sort(data.VyNLtemp);
%     data.VyNLtemp(1:round(Param.Trim/200*length(data.VyNLtemp))  )=100;
%     data.VyNLtemp(round( (1-Param.Trim/200)*length(data.VyNLtemp)) :end )=100;
%     data.VyNLtemp(data.VyNLtemp>1)=[];
% end








data.time=[data.time,toc/60]; % time passed since each angle measure loop (minutes)

[Temper,TempStatus]=GetTemper(InstQD);   % get temperature
disp(TempStatus)
data.T = [data.T, Temper];
%data record
measurerecord0=[Temper,data.VxL(m),data.VyL(m),data.VxNL(m),data.VyNL(m),data.time(m)];
%[Status,He]=InstQD.GetPPMSItem(66,1,true);

%plot data linear
% pause(0.01);

close(gcf);





subplot(7,2,[1,3,5]);
hold on; box on;
e=plot(data.T,data.VxL);
title('PtVxL');
xlabel('T (K)');
ylabel('PtVxL (V)');

subplot(7,2,[2,4,6]);
hold on; box on;
e=plot(data.T,data.VyL);
title('PtVyL');
xlabel('T (K)');
ylabel('PtVyL (V)');

subplot(7,2,[7,9,11]);
hold on; box on;
e=plot(data.T,data.VxNL);
title('PtVxNL');
xlabel('T (K)');
ylabel('PtVxNL (V)');

subplot(7,2,[8,10,12]);
hold on; box on;
e=plot(data.T,data.VyNL);
title('PtVyNL');
xlabel('T (K)');
ylabel('PtVyNL (V)');




% pause(0.01);

%char() is conversion function to str
%num2str() is conversion function from float to str
fileNameHeader = [char(time),'_',num2str(Param.InitialTemp),'K-',num2str(Param.Temp(TempIndex)),'K',Param.fileHeader,num2str(Param.Imax(CurrentIndex)*1e6),'uA_',num2str(Param.Ifrequency(FreqIndex)),'Hz'];

fileName=fullfile(pwd,Param.folder,[fileNameHeader,'.txt']);                     %make datafile title
dlmwrite(fileName,measurerecord0,'-append','delimiter',' ','precision',9);
% pause(0.1);

m=m+1;

fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];


try
    fileNameJpg=fullfile(pwd,Param.folder,[fileNameHeader,'.jpg']);                     %make datafile title
    saveas(gcf, fileNameJpg);
    
    %fileNameFig=fullfile(pwd,Param.folder,[fileNameHeader,'.fig']);                     %make datafile title
    %saveas(gcf, fileNameFig);
end






