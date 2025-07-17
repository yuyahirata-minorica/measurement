function NL_fieldDepStable_LI5640_Input_5_6_OutPut_2_1(nF,DR1,DR2 ) 
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

% K6221 parameters
Param.VComp = 50;
Param.Iac1 = [3.5e-3, 3.5e-3, 3.5e-3, 3.5e-3, 3.5e-3]; %5.0e-3; %A
Param.Iac1 = [3.5e-3,3.1e-3,2.7e-3,2.2e-3,1.6e-3]; %A
Param.Iac1 = [2.7e-3,2.2e-3,1.6e-3]; %A
%Param.Iac1 = [3.1e-3,2.7e-3,2.2e-3,1.6e-3]; %A
Param.Iac2 = [100e-6,100e-6,100e-6,100e-6,100e-6]; %A
%Param.Iac2 = [100e-6]; %A
Param.Ifrequency_ac1=3.743; %Hz
Param.Ifrequency_ac2=18.715; %Hz
%Param.Ifrequency_ac1=1.743; %Hz
%Param.Ifrequency_ac2=8.715; %Hz

% Trim% precent extrem value exclude
Param.Trim =50;

%10: Heater on MoGe, 11: Heaeter on GGG, 12: MoGe
Param.GPIB6221_ac1 = 11;
Param.GPIB6221_off = 10;
Param.GPIB6221_ac2 = 12;
Param.GPIB5640_1 = 3;
Param.GPIB5640_2 = 5;
Param.GPIB5650_3 = 6;
Param.GPIB5650_4 = 7;

%Parameter for PPMS
%Heater on MoGe
Param.Temp=[4.5,4.647,4.775,4.904,5.022];
Param.Temp=[4.647,4.775,4.904,5.022];
%Heater on GGG
Param.Temp=[4.473,4.623,4.752,4.883,5.002];
Param.Temp=[4.48,4.63,4.759,4.89,5.009];
Param.Temp=[4.5,4.65,4.779,4.91,5.029];
Param.Temp=[4.52,4.67,4.799,4.93,5.049];
Param.TempRate=3;                                                          %Set the Rate to change temperature
Param.Tempnum=length(Param.Temp);                                          %Count the number of listed items
Param.time_wait_T = 300;                                                   %wait time for each T to settle (s)
%Param.Tc = 10.10;
%Param.TempFinal = 10;

%T=4.5 K and IH=3.5 mA [for 90deg, for 0deg]
Param.Hstart=[24000,24000];
Param.Hend=[4000,4000];

%Param.H =[90000:-4000:Param.Hstart,Param.Hstart:-100:Param.Hend,Param.Hend:-4000:-Param.Hend,-Param.Hend:-100:-Param.Hstart,-Param.Hstart:-4000:-90000];

%Set the wait time after setting each magmetic field
Param.waitH = 10;
%Set the Rate to change field during measurement
Param.Hrate=100;                                                            

Param.angle = [90,0,75,60,45,30,15];
%Param.angle = [60,0];
Param.angle = [90,0,75];
Param.anglenum = length(Param.angle);
Param.time_wait_angle = 15;                       
%wait time for each position to settle

Param.Sekisan=25;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initializing the instruments %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % No 1, Instrument:
% Keithley 6221 AC Source set sine mode,

%Heater current
[Sta,Instrs.K6221_ac1] = F_6221(0,Param.GPIB6221_ac1); % Initializing 6221
Sta = F_6221(3,Instrs.K6221_ac1,1e-9,Param.Ifrequency_ac1(1),Param.VComp); % set 1nA current Sin wave to 6221;
Sta = F_6221(98,Instrs.K6221_ac1); % begin output;

%Turn off another Heater
[Sta,Instrs.K6221_off] = F_6221(0,Param.GPIB6221_off); % Initializing 6221
Sta = F_6221(99,Instrs.K6221_off) ;

%MoGe current
[Sta,Instrs.K6221_ac2] = F_6221(0,Param.GPIB6221_ac2); % Initializing 6221
%synchronization mode with another K6221
Sta = F_6221(7,Instrs.K6221_ac2,1e-9,Param.Ifrequency_ac2(1),Param.VComp); % set 1nA current Sin wave to 6221;
Sta = F_6221(98,Instrs.K6221_ac2); % begin output;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%No 2, LockIn
% Result=fscanf(Instrs.LI5640)   % quirery

% Lock-in freq index: nf
nF1=5
nF2=10
nF3=2
%nF4=7
nF4=3

%set dynamical reserve 0 HIGH; 1 MEDIUM; 2 LOW for LI5640
DR1=1
DR2=1
%set dynamical reserve HIGH, MED, LOW for LI5650
DR3='MED'
DR4='MED'

% SENSITIVITY code = 0-26 (numerical) for LI5640
%0-2nV;1-5nV;2-10nV;3-20nV;4-50nV;5-100nV;6-200nV;7-500nV;8-1uV;9-2uV;10-5uV;11-10uV;12-20uV;13-50uV;14-100uV;15-200uV;16-500uV;17-1mV;18-2mV;19-5mV;20-10mV;21-20mV;22-50mV;23-100mV;24-200mV;25-500mV;
VSens1=19
VSens2=14
% SENSITIVITY for LI5650
VSens3='50e-6'
VSens4='500e-6'

[Sta,Instrs.LI5640_1]=F_LI5640(0,Param.GPIB5640_1,nF1,VSens1,DR1);
[Sta,Instrs.LI5640_2]=F_LI5640(0,Param.GPIB5640_2,nF2,VSens2,DR2);
[Sta,Instrs.LI5650_3]=F_LI5650(0,Param.GPIB5650_3,nF3,VSens3,DR3);
[Sta,Instrs.LI5650_4]=F_LI5650(0,Param.GPIB5650_4,nF4,VSens4,DR4);


% data file param
%Param.folder = ['V-B_LI5640_MoGeVolt_12-8_K6221ac1_HeaterOnMeGeCurr_13-14_K6221ac2_MoGeCurr_11-7'];
Param.folder = ['V-B_LI5640_MoGeVolt_12-8_K6221ac1_HeaterOnGGGCurr_10-9_K6221ac2_MoGeCurr_11-7'];
%Param.folder = ['V-B_LI5640_MoGeVolt_12-8_K6221ac1_HeaterOnMeGeCurr_13-14_K6221ac2_MoGeCurr_11-7_Sample2'];
%Param.folder = ['V-B_LI5640_MoGeVolt_12-8_K6221ac1_HeaterOnGGGCurr_10-9_K6221ac2_MoGeCurr_11-7_Sample2'];

switch DR1
    case 0
        
        Hoge1 = 'Hi'
    case 1
        Hoge1 = 'Med'
    case 2
        Hoge1 = 'Lo'
end


switch DR2
    case 0
        Hoge2 = 'Hi'
    case 1
        Hoge2 = 'Med'
    case 2
        Hoge2 = 'Lo'
end

Param.fileHeader = ['_',num2str(nF1),'f_',Hoge1,'_VSens',num2str(VSens1),'_',num2str(nF2),'f_',Hoge2,'_VSens',num2str(VSens2),'_',num2str(nF3),'f_',DR3,'_VSens_',VSens3,'_',num2str(nF4),'f_',DR4,'_VSens_',VSens4,'_',num2str(Param.Sekisan),'ave_'];


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

%  set to each H
%  set Field to the start point, linear, Driven

%=SetFieldPPMS(QDIn,Targ,Rate,Appr=1:Linear,2:NoOvershoot,3:Oscillate,Mode=1:Persistent,2:Driven)
%Sta=SetFieldPPMS(InstQD,0,100,1,1); %  to Zero
%WaitFieldStable(QDIn,endMode=1:StablePersistent,2:StableDriven)
%Sta=WaitFieldStable(InstQD,1);


% temp loop (1st)
for tempIndex=1:1%Param.Tempnum

    for currIndex=1:length(Param.Iac1)
        
        for freqIndex = 1:length(Param.Ifrequency_ac1)
            
            % abort I current;
            Sta = F_6221(99,Instrs.K6221_ac1) ;
            Sta = F_6221(99,Instrs.K6221_ac2) ;
            pause(1);
            % set Sin wave current to 6221;
            Sta = F_6221(3,Instrs.K6221_ac1,Param.Iac1(currIndex),Param.Ifrequency_ac1(freqIndex),Param.VComp) ;
            %Sta = F_6221(3,Instrs.K6221_ac2,Param.Iac2(currIndex),Param.Ifrequency_ac2(freqIndex),Param.VComp) ;
            % set Sin wave current to 6221 and set to external trigger mode;
            Sta = F_6221(7,Instrs.K6221_ac2,Param.Iac2(currIndex),Param.Ifrequency_ac2(freqIndex),Param.VComp) ;
            % begin output;
            Sta = F_6221(98,Instrs.K6221_ac1) ;
            Sta = F_6221(98,Instrs.K6221_ac2) ;            
            
            for angleIndex = 1:length(Param.angle)
                    
                if angleIndex==1 %reverse the field direction when angleIndex is even
                    Param.H =[60000:-4000:Param.Hstart(1),Param.Hstart(1):-100:Param.Hend(1),Param.Hend(1):-4000:-Param.Hend(1),-Param.Hend(1):-100:-Param.Hstart(1),-Param.Hstart(1):-4000:-60000];
                
                elseif angleIndex==2
                    Param.H =[60000:-4000:Param.Hstart(2),Param.Hstart(2):-100:Param.Hend(2),Param.Hend(2):-4000:-Param.Hend(2),-Param.Hend(2):-100:-Param.Hstart(2),-Param.Hstart(2):-4000:-60000];

                else
                    Param.H =[60000:-4000:Param.Hstart(1),Param.Hstart(1):-100:Param.Hend(1),Param.Hend(1):-4000:-Param.Hend(1),-Param.Hend(1):-100:-Param.Hstart(1),-Param.Hstart(1):-4000:-60000];
                end
                
                if rem(angleIndex,2) ==0 %reverse the field direction when angleIndex is even
                    Param.H =flip(Param.H);                                                        %Set the Field parameter
                end

                %set waiting time before measurement (wait for steady state under heater and cernox heating)
                Sta=SetFieldPPMS(InstQD,Param.H(1),100,1,2); %  to Zero
                Sta=WaitFieldStable(InstQD,2);
                
                %Sta=SetTemper(InstQD,Param.Temp(tempIndex),Param.TempRate,2);%2:NoOvershoot
                Sta=SetTemper(InstQD,Param.Temp(currIndex),Param.TempRate,2);%2:NoOvershoot
                Sta=WaitTempStable(InstQD);
                pause(Param.time_wait_T);
                
                
                
                fieldList = [];  data.Vx1 = []; data.Vy1=[];  data.Vx2 = []; data.Vy2=[]; data.Vx3 = []; data.Vy3=[]; data.Vx4 = []; data.Vy4=[]; data.time=[]; m=1;
                data.Vx1Std = []; data.Vy1Std=[];data.Vx2Std = []; data.Vy2Std=[]; data.Vx3Std = []; data.Vy3Std=[]; data.Vx4Std = []; data.Vy4Std=[];
                
                time=datetime('now','Format','yyyy-MMdd-HHmm');
                % for rotator option for Dynacool
                Sta=SetDynacoolPos(InstQD,Param.angle(angleIndex));
                %Sta=Setppmspos(InstQD,Param.angle(angleIndex));
                pause(Param.time_wait_angle);
                
                tic;
                for fieldIndex = 1:length(Param.H)
                    
                  %  CheckHe(InstQD);
                    fieldSetPoint=Param.H(fieldIndex);
                    
                    [m,fieldList,data]=SweepFieldMeasure(InstQD,Param,Instrs,fieldSetPoint,fieldList,tempIndex,currIndex,freqIndex,angleIndex,time,m,data);
                    
                end
            end
            
            close all;
            
            %delete the variable in which data is saved for plotting
            clear data;
            clear H;
            
        end
        
    end % end of temperature loop (1st)
    
end

%set final state after measurement
%=SetFieldPPMS(QDIn,Targ,Rate,Appr=1:Linear,2:NoOvershoot,3:Oscillate,Mode=1:Persistent,2:Driven)
Sta=SetFieldPPMS(InstQD,0,100,1,2); %  to Zero
%WaitFieldStable(QDIn,endMode=1:StablePersistent,2:StableDriven)
Sta=WaitFieldStable(InstQD,2);

% Sta=SetTemper(InstQD,Param.TempFinal,3,1);

% abort ac current;
Sta = F_6221(99,Instrs.K6221_ac1) ;
fclose(Instrs.K6221_ac1);
Sta = F_6221(99,Instrs.K6221_ac2) ;
fclose(Instrs.K6221_ac2);

%clear all parameters
clear all;
%clear command window
clc;
delete(instrfind);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  sweep field and measure FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [m,FieldList,data]=SweepFieldMeasure(InstQD,Param,Instrs,FieldSetPoint,FieldList,TempIndex,CurrentIndex,FreqIndex,AngleIndex,time,m,data)
%m: var for magnetic field plot and record
%H: list for field data
%data0: list for resist data

Path=fullfile(pwd,'QDInstrument.dll');
QDdll = NET.addAssembly(Path);
import QuantumDesign.QDInstrument.*;
import QuantumDesign.QDInstrument.QDInstrumentFactory.*;
import QuantumDesign.QDInstrument.QDInstrumentBase.*;

Sta=SetFieldPPMS(InstQD,FieldSetPoint,Param.Hrate,1,2);
Sta=WaitFieldStable(InstQD,2);
pause(Param.waitH);


for me = [1:Param.Sekisan];
    try
        pause(0.05);
        [Sta,Result1] = F_LI5640(1,Instrs.LI5640_1);
        data.Vy1temp(me)=Result1(2)
        data.Vx1temp(me)=Result1(1)
        [Sta,Result2] = F_LI5640(1,Instrs.LI5640_2);
        data.Vy2temp(me)=Result2(2)
        data.Vx2temp(me)=Result2(1)
        [Sta,Result3] = F_LI5650(1,Instrs.LI5650_3);
        data.Vy3temp(me)=Result3(2)
        data.Vx3temp(me)=Result3(1)
        [Sta,Result4] = F_LI5650(1,Instrs.LI5650_4);
        data.Vy4temp(me)=Result4(2)
        data.Vx4temp(me)=Result4(1)
        
    end
end

% remove extrem value
try
 
    data.Vx1temp=sort(data.Vx1temp);
    data.Vx1temp(1:round(Param.Trim/200*length(data.Vx1temp))  )=100;
    data.Vx1temp(round( (1-Param.Trim/200)*length(data.Vx1temp)) :end )=100;
    data.Vx1temp(data.Vx1temp>1)=[];
    
    data.Vy1temp=sort(data.Vy1temp);
    data.Vy1temp(1:round(Param.Trim/200*length(data.Vy1temp))  )=100;
    data.Vy1temp(round( (1-Param.Trim/200)*length(data.Vy1temp)) :end )=100;
    data.Vy1temp(data.Vy1temp>1)=[];

    data.Vx2temp=sort(data.Vx2temp);
    data.Vx2temp(1:round(Param.Trim/200*length(data.Vx2temp))  )=100;
    data.Vx2temp(round( (1-Param.Trim/200)*length(data.Vx2temp)) :end )=100;
    data.Vx2temp(data.Vx2temp>1)=[];
    
    data.Vy2temp=sort(data.Vy2temp);
    data.Vy2temp(1:round(Param.Trim/200*length(data.Vy2temp))  )=100;
    data.Vy2temp(round( (1-Param.Trim/200)*length(data.Vy2temp)) :end )=100;
    data.Vy2temp(data.Vy2temp>1)=[];

    data.Vx3temp=sort(data.Vx3temp);
    data.Vx3temp(1:round(Param.Trim/200*length(data.Vx3temp))  )=100;
    data.Vx3temp(round( (1-Param.Trim/200)*length(data.Vx3temp)) :end )=100;
    data.Vx3temp(data.Vx3temp>1)=[];
    
    data.Vy3temp=sort(data.Vy3temp);
    data.Vy3temp(1:round(Param.Trim/200*length(data.Vy3temp))  )=100;
    data.Vy3temp(round( (1-Param.Trim/200)*length(data.Vy3temp)) :end )=100;
    data.Vy3temp(data.Vy3temp>1)=[];

    data.Vx4temp=sort(data.Vx4temp);
    data.Vx4temp(1:round(Param.Trim/200*length(data.Vx4temp))  )=100;
    data.Vx4temp(round( (1-Param.Trim/200)*length(data.Vx4temp)) :end )=100;
    data.Vx4temp(data.Vx4temp>1)=[];
    
    data.Vy4temp=sort(data.Vy4temp);
    data.Vy4temp(1:round(Param.Trim/200*length(data.Vy4temp))  )=100;
    data.Vy4temp(round( (1-Param.Trim/200)*length(data.Vy4temp)) :end )=100;
    data.Vy4temp(data.Vy4temp>1)=[];

end




% Field
FieldList=[FieldList,FieldSetPoint];

%data
data.Vx1=[data.Vx1,mean(data.Vx1temp)];
data.Vy1=[data.Vy1,mean(data.Vy1temp)];
data.Vx1Std = [data.Vx1Std,std(data.Vx1temp)];
data.Vy1Std = [data.Vy1Std,std(data.Vy1temp)];

data.Vx2=[data.Vx2,mean(data.Vx2temp)];
data.Vy2=[data.Vy2,mean(data.Vy2temp)];
data.Vx2Std = [data.Vx2Std,std(data.Vx2temp)];
data.Vy2Std = [data.Vy2Std,std(data.Vy2temp)];

data.Vx3=[data.Vx3,mean(data.Vx3temp)];
data.Vy3=[data.Vy3,mean(data.Vy3temp)];
data.Vx3Std = [data.Vx3Std,std(data.Vx3temp)];
data.Vy3Std = [data.Vy3Std,std(data.Vy3temp)];

data.Vx4=[data.Vx4,mean(data.Vx4temp)];
data.Vy4=[data.Vy4,mean(data.Vy4temp)];
data.Vx4Std = [data.Vx4Std,std(data.Vx4temp)];
data.Vy4Std = [data.Vy4Std,std(data.Vy4temp)];

data.time=[data.time,toc/60]; % time passed since each angle measure loop (minutes)

[Temper,Sta]=GetTemper(InstQD);   % get temperature

%data record
measurerecord0=[FieldSetPoint,Temper,data.Vx1(m),data.Vy1(m),data.Vx1Std(m),data.Vy1Std(m),data.Vx2(m),data.Vy2(m),data.Vx2Std(m),data.Vy2Std(m),data.Vx3(m),data.Vy3(m),data.Vx3Std(m),data.Vy3Std(m),data.Vx4(m),data.Vy4(m),data.Vx4Std(m),data.Vy4Std(m),data.time(m)];
%[Status,He]=InstQD.GetPPMSItem(66,1,true);

%plot data linear
pause(0.01);

close(gcf);

subplot(19,2,[1,3,5,7]);
hold on; box on;
e=errorbar(FieldList,data.Vx1,data.Vx1Std);
e=setErrorBar(e,'r');
xlim([min(Param.H) max(Param.H)]);
%title('Vx1');
%xlabel('Phase (deg)');
ylabel('Vx1 (V)');

subplot(19,2,[2,4,6,8]);
hold on; box on;
e=errorbar(FieldList,data.Vy1,data.Vy1Std);
e=setErrorBar(e,'r');
xlim([min(Param.H) max(Param.H)]);
%title('Vy1');
%xlabel('Phase (deg)');
ylabel('Vy1 (V)');

subplot(19,2,[11,13,15,17]);
hold on; box on;
e=errorbar(FieldList,data.Vx2,data.Vx2Std);
e=setErrorBar(e,'r');
xlim([min(Param.H) max(Param.H)]);
%title('Vx2');
%xlabel('Phase (deg)');
ylabel('Vx2 (V)');

subplot(19,2,[12,14,16,18]);
hold on; box on;
e=errorbar(FieldList,data.Vy2,data.Vy2Std);
e=setErrorBar(e,'r');
xlim([min(Param.H) max(Param.H)]);
%title('Vy2');
%xlabel('Phase (deg)');
ylabel('Vy2 (V)');

subplot(19,2,[21,23,25,27]);
hold on; box on;
e=errorbar(FieldList,data.Vx3,data.Vx3Std);
e=setErrorBar(e,'r');
xlim([min(Param.H) max(Param.H)]);
%title('Vx3');
ylabel('Vx3 (V)');

subplot(19,2,[22,24,26,28]);
hold on; box on;
e=errorbar(FieldList,data.Vy3,data.Vy3Std);
e=setErrorBar(e,'r');
xlim([min(Param.H) max(Param.H)]);
%title('Vy3');
ylabel('Vy3 (V)');


subplot(19,2,[31,33,35,37]);
hold on; box on;
e=errorbar(FieldList,data.Vx4,data.Vx4Std);
e=setErrorBar(e,'r');
xlim([min(Param.H) max(Param.H)]);
%title('Vx4');
xlabel('H (Oe)');
ylabel('Vx4 (V)');

subplot(19,2,[32,34,36,38]);
hold on; box on;
e=errorbar(FieldList,data.Vy4,data.Vy4Std);
e=setErrorBar(e,'r');
xlim([min(Param.H) max(Param.H)]);
%title('Vy4');
xlabel('H (Oe)');
ylabel('Vy4 (V)');


pause(0.01);

%char() is conversion function to str
%num2str() is conversion function from float to str
%fileNameHeader = [char(time),Param.fileHeader,num2str(Param.Temp(TempIndex)),'K_6221ac1_',num2str(Param.Iac1(CurrentIndex)),'A_',num2str(Param.Ifrequency_ac1(FreqIndex)),'Hz_6221ac2_',num2str(Param.Iac2(CurrentIndex)),'A_',num2str(Param.Ifrequency_ac2(FreqIndex)),'Hz_','SmallHstep',num2str(Param.Hstart(TempIndex)*1e-4),'T-',num2str(Param.Hend(TempIndex)*1e-4),'T_',num2str(Param.angle(AngleIndex)),'deg'];

if AngleIndex==1
    fileNameHeader = [char(time),Param.fileHeader,num2str(Param.Temp(CurrentIndex)),'K_6221ac1_',num2str(Param.Iac1(CurrentIndex)),'A_',num2str(Param.Ifrequency_ac1(FreqIndex)),'Hz_6221ac2_',num2str(Param.Iac2(CurrentIndex)),'A_',num2str(Param.Ifrequency_ac2(FreqIndex)),'Hz_','SmallHstep',num2str(Param.Hstart(2*TempIndex-1)*1e-4),'T-',num2str(Param.Hend(2*TempIndex-1)*1e-4),'T_',num2str(Param.angle(AngleIndex)),'deg'];
elseif AngleIndex==2
    fileNameHeader = [char(time),Param.fileHeader,num2str(Param.Temp(CurrentIndex)),'K_6221ac1_',num2str(Param.Iac1(CurrentIndex)),'A_',num2str(Param.Ifrequency_ac1(FreqIndex)),'Hz_6221ac2_',num2str(Param.Iac2(CurrentIndex)),'A_',num2str(Param.Ifrequency_ac2(FreqIndex)),'Hz_','SmallHstep',num2str(Param.Hstart(2*TempIndex)*1e-4),'T-',num2str(Param.Hend(2*TempIndex)*1e-4),'T_',num2str(Param.angle(AngleIndex)),'deg'];
else
    fileNameHeader = [char(time),Param.fileHeader,num2str(Param.Temp(CurrentIndex)),'K_6221ac1_',num2str(Param.Iac1(CurrentIndex)),'A_',num2str(Param.Ifrequency_ac1(FreqIndex)),'Hz_6221ac2_',num2str(Param.Iac2(CurrentIndex)),'A_',num2str(Param.Ifrequency_ac2(FreqIndex)),'Hz_','SmallHstep',num2str(Param.Hstart(2*TempIndex-1)*1e-4),'T-',num2str(Param.Hend(2*TempIndex-1)*1e-4),'T_',num2str(Param.angle(AngleIndex)),'deg'];
end

fileName=fullfile(pwd,Param.folder,[fileNameHeader,'.txt']);                     %make datafile title
dlmwrite(fileName,measurerecord0,'-append','delimiter',' ','precision',9);
pause(0.1);

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




function ErrorBar=setErrorBar(ErrorBar,Color)
E=ErrorBar;
E.Marker='o';
E.MarkerSize = 3;
E.MarkerEdgeColor = Color;
E.MarkerFaceColor = Color;
E.Color=Color;
E.LineWidth=1;



