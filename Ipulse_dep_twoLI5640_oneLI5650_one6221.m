function NL_fieldDepStable_LI5640_Input_5_6_OutPut_2_1(nF,DR2,DR3) 
// nF = what harmonic to lock-in 
// Curr & Freq = input current 
// DR = 0 (high), 1 (medium), 2 (low)

//////////////////////////////////////////////////////////////////////////////////////


//// Parameter setting ////////////////
//////////////////////////////////////////////////////////////////////////////////
//clear command window
clc;
// clear figure window
close all;
//delete all instruments' ports
delete(instrfind);

//Param.Iheater = 2.0e-3;
//Param.Imax = [400e-6, 400e-6, 300e-6, 300e-6, 300e-6, 300e-6, 300e-6, 300e-6]; //A
Param.Imax = [400e-6, 400e-6]; //A
Param.VComp = 50; //V
Param.Ifrequency = [6.7]; //Hz
//Param.PulseAmp=2e-3; //A
//Param.Ipulse =[10e-3:-0.75e-3:-10e-3,-10e-3:0.75e-3:10e-3]; //A
Param.Ipulse =[40e-3:-5e-3:-40e-3,-40e-3:5e-3:40e-3]; //A
//Param.Ipulse =[40e-3:-2e-3:-40e-3,-40e-3:2e-3:40e-3]; //A
//Param.Ipulse =[60e-3:-3e-3:-60e-3,-60e-3:3e-3:60e-3]; //A
//Param.Ipulse =[-60e-3:3e-3:60e-3,60e-3:-3e-3:-60e-3]; //A //opposite direction
//Param.Ipulse =[9e-4,-9e-4]; //A
//Param.PulseLength=0.08; //s
Param.PulseLength=0.00001; //s
Param.waitAfterIpulse=60 //s

// Trim// precent extrem value exclude
Param.Trim =50;

//Param.GPIB6221H = 12;
Param.GPIB6221 = 12;


Param.GPIB5650_1 = 7;
Param.GPIB5640_2 = 6;
Param.GPIB5640_3 = 5; 

//Parameter for PrPMS
Param.Temp = [100];

Param.TempRate=3;                                                          //Set the Rate to change temperature
Param.Tempnum=length(Param.Temp);                                          //Count the number of listed items
Param.time_wait_T = 10;                                                   //wait time for each T to settle (s)

Param.angle = [90];
Param.anglenum = length(Param.angle);
Param.time_wait_angle = 1;                                                 //wait time for each position to settle

Param.Sekisan=25;

//////////////////////////////////////////////////////////////////////////////////////
//// Initializing the instruments ////////////////
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////
// // No 1, Instrument:
// Keithley 6221 AC Source set sine mode,

//[Sta,Instrs.K6221H] = F_6221(0,Param.GPIB6221H); // Initializing 6221
//Sta = F_6221(5,Instrs.K6221H,Param.Iheater,Param.VComp); // set dc current to 6221 and begin output;

[Sta,Instrs.K6221] = F_6221(0,Param.GPIB6221); // Initializing 6221
Sta = F_6221(8,Instrs.K6221,max(Param.Ipulse)); // set auto-range to pulse amplitude;
Sta = F_6221(3,Instrs.K6221,1e-9,Param.Ifrequency(1),Param.VComp); // set 1nA current Sin wave to 6221;
Sta = F_6221(98,Instrs.K6221); // begin output;

//////////////////////////////////////////////////////////////////////////////////////
//No 2, LockIn
// Result=fscanf(Instrs.LI5640)   // quirery

nF1=1
nF2=2
nF3=3


//set dynamical reserve 0 HIGH; 1 MEDIUM; 2 LOW for LI5640
DR1='LOW'
DR2=1
DR3=1
// SENSITIVITY = 0-26 (numerical)
//0-2nV;1-5nV;2-10nV;3-20nV;4-50nV;5-100nV;6-200nV;7-500nV;8-1uV;9-2uV;10-5uV;11-10uV;12-20uV;13-50uV;14-100uV;15-200uV;16-500uV;17-1mV;18-2mV;19-5mV;20-10mV;21-20mV;22-50mV;23-100mV;24-200mV;25-500mV;

//for transverse resistivity
//VSensL=12
//VSensNL=9

//for longitudinal resistivity
VSens1='100e-3'
VSens2=16
VSens3=17


[Sta,Instrs.LI5650_1]=F_LI5650(0,Param.GPIB5650_1,nF1,VSens1,DR1); //7:500nV   12:20uV range
[Sta,Instrs.LI5640_2]=F_LI5640(0,Param.GPIB5640_2,nF2,VSens2,DR2); //7:500nV   12:20uV range
[Sta,Instrs.LI5640_3]=F_LI5640(0,Param.GPIB5640_3,nF3,VSens3,DR3);

// data file param
Param.folder = ['magnetite5_pulse100m_wait60s_pulsewidth0000001_4_26_CurrentLock_In_I8-10_V7-11'];
//Param.folder = ['magnetite5_pulse80m_wait60s_pulsewidth001_verticleB-15000_3_27_CurrentLock_In_I8-9_V7-11'];
//Param.folder = ['magnetite5_pulse100m_wait60s_pulsewidth001_3_27_CurrentLock_In_I8-9_V12-13'];


switch DR2
    case 0
        
        HogeL = 'Hi'
    case 1
        HogeL = 'Med'
    case 2
        HogeL = 'Lo'
end


switch DR3
    case 0
        HogeNL = 'Hi'
    case 1
        HogeNL = 'Med'
    case 2
        HogeNL = 'Lo'
end

Param.fileHeader = ['_',num2str(nF1),'f_',HogeL,'_VSens',num2str(VSens1),'_',num2str(nF2),'f_',HogeNL,'_VSens',num2str(VSens2),'_',num2str(nF3),'f_',HogeL,'_VSens',num2str(VSens3),'_',num2str(Param.Sekisan),'ave_'];                                                      //file path


//////////////////////////////////////////////////////////////////////////////////////
//No 3, PPMS
InstQD=ConQDInstru; // connect to the Dynacool or PPMS


Path=fullfile(pwd,'QDInstrument.dll');
QDdll = NET.addAssembly(Path);
import QuantumDesign.QDInstrument.*;
import QuantumDesign.QDInstrument.QDInstrumentFactory.*;
import QuantumDesign.QDInstrument.QDInstrumentBase.*;

//////////////////////////////////////////////////////////////////////////////////////
//// Measurement loop          ////////////////
////////////////////////////////////////////////////////////////////////////////////

mkdir(Param.folder);

//SetFieldPPMS(QDIn,Targ,Rate,Appr=1:Linear,2:NoOvershoot,3:Oscillate,Mode=1:Persistent,2:Driven)
//Sta=SetFieldPPMS(InstQD,15000,100,1,2); //  set H
//WaitFieldStable(QDIn,endMode=1:StablePersistent,2:StableDriven)
//Sta=WaitFieldStable(InstQD,2);

// for rotator option for Dynacool
//Sta=SetDynacoolPos(InstQD,50);
//Sta=Setppmspos(InstQD,Param.angle(angleIndex));
//pause(Param.time_wait_angle);

//set temperature
//Sta=SetTemper(InstQD,110,3,1);
//Sta=WaitTempStable(InstQD);


// for rotator option for Dynacool
//Sta=SetDynacoolPos(InstQD,90);
//Sta=Setppmspos(InstQD,Param.angle(angleIndex));
//pause(Param.time_wait_angle);

//SetFieldPPMS(QDIn,Targ,Rate,Appr=1:Linear,2:NoOvershoot,3:Oscillate,Mode=1:Persistent,2:Driven)
//Sta=SetFieldPPMS(InstQD,0,100,1,1); //  set H
//WaitFieldStable(QDIn,endMode=1:StablePersistent,2:StableDriven)
//Sta=WaitFieldStable(InstQD,1);




// temp loop (1st)
for tempIndex=1:Param.Tempnum

    //set field
    //Sta=SetFieldPPMS(InstQD,Param.Ipulse(1),100,1,2); //  to first value
    //Sta=WaitFieldStable(InstQD,2);
    
    //set temperature
    Sta=SetTemper(InstQD,Param.Temp(tempIndex),Param.TempRate,1);
    Sta=WaitTempStable(InstQD);
    
    // current density
    for currIndex=1:length(Param.Imax)
        
        for freqIndex = 1:length(Param.Ifrequency)
            
            // abort I current;
            Sta = F_6221(99,Instrs.K6221) ;
            pause(1);
            // set current Sin wave to 6221;
            Sta = F_6221(3,Instrs.K6221,Param.Imax(currIndex),Param.Ifrequency(freqIndex),Param.VComp) ;
            // begin output;
            Sta = F_6221(98,Instrs.K6221) ;

            //set waiting time before measurement
          pause(Param.time_wait_T);
                        
            for angleIndex = 1:length(Param.angle)                
                
                IpulseList = [];   data.Vx1 = []; data.Vy1=[];  data.Vx2 = []; data.Vy2=[]; data.Vx3 = []; data.Vy3=[]; data.time=[]; m=1;
                data.Vx1Std = []; data.Vy1Std=[];data.Vx2Std = []; data.Vy2Std=[]; data.Vx3Std = []; data.Vy3Std=[];
                
                time=datetime('now','Format','yyyy-MMdd-HHmm');
                // for rotator option for Dynacool
                //Sta=SetDynacoolPos(InstQD,Param.angle(angleIndex));
                Sta=Setppmspos(InstQD,Param.angle(angleIndex));
                pause(Param.time_wait_angle);
                
                tic;
                for IpulseIndex = 1:length(Param.Ipulse)
                    
                  //  CheckHe(InstQD);
                    IpulseSetPoint=Param.Ipulse(IpulseIndex);
                    
                    [m,IpulseList,data]=SweepFieldMeasure(InstQD,Param,Instrs,IpulseSetPoint,IpulseList,tempIndex,currIndex,freqIndex,angleIndex,time,m,data);
                    
                end
            end
            
            close all;
            
            //delete the variable in which data is saved for plotting
            clear data;
            clear H;
            
        end
        
    end // end of temperature loop (1st)
    
end

//set final state after measurement
//=SetFieldPPMS(QDIn,Targ,Rate,Appr=1:Linear,2:NoOvershoot,3:Oscillate,Mode=1:Persistent,2:Driven)
//Sta=SetFieldPPMS(InstQD,0,100,1,2); //  to Zero
//WaitFieldStable(QDIn,endMode=1:StablePersistent,2:StableDriven)
//Sta=WaitFieldStable(InstQD,2);

// Sta=SetTemper(InstQD,Param.TempFinal,3,1);

// abort dc current;
//Sta = F_6221(102,Instrs.K6221H) ;
//fclose(Instrs.K6221H);

// abort ac current;
Sta = F_6221(99,Instrs.K6221) ;
fclose(Instrs.K6221);

//clear all parameters
clear all;
//clear command window
clc;
delete(instrfind);



//////////////////////////////////////////////////////////////////////////////////////
//  sweep current and measure FUNCTIONS
//////////////////////////////////////////////////////////////////////////////////////
function [m,IpulseList,data]=SweepFieldMeasure(InstQD,Param,Instrs,IpulseSetPoint,IpulseList,TempIndex,CurrentIndex,FreqIndex,AngleIndex,time,m,data)
//m: var for magnetic field plot and record
//H: list for field data
//data0: list for resist data

Path=fullfile(pwd,'QDInstrument.dll');
QDdll = NET.addAssembly(Path);
import QuantumDesign.QDInstrument.*;
import QuantumDesign.QDInstrument.QDInstrumentFactory.*;
import QuantumDesign.QDInstrument.QDInstrumentBase.*;

Sta = F_6221(7,Instrs.K6221,IpulseSetPoint); // set dc offset to sine wave;
pause(Param.PulseLength); // offset duration time
Sta = F_6221(7,Instrs.K6221,0); // end dc offset;
pause(Param.waitAfterIpulse);


for me = [1:Param.Sekisan];
    try
        pause(0.05);
        [Sta,Result1] = F_LI5650(1,Instrs.LI5650_1);
        data.Vy1temp(me)=Result1(2)
        data.Vx1temp(me)=Result1(1)
        [Sta,Result2] = F_LI5640(1,Instrs.LI5640_2);
        data.Vy2temp(me)=Result2(2)
        data.Vx2temp(me)=Result2(1)
        [Sta,Result3] = F_LI5640(1,Instrs.LI5640_3);
        data.Vy3temp(me)=Result3(2)
        data.Vx3temp(me)=Result3(1)
        
    end
end

// remove extrem value
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

end



// angle
IpulseList=[IpulseList,IpulseSetPoint];

//  detector 2f
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

data.time=[data.time,toc/60]; // time passed since each angle measure loop (minutes)

[Temper,Sta]=GetTemper(InstQD);   // get temperature

//data record
measurerecord0=[IpulseSetPoint,Temper,data.Vx1(m),data.Vy1(m),data.Vx1Std(m),data.Vy1Std(m),data.Vx2(m),data.Vy2(m),data.Vx2Std(m),data.Vy2Std(m),data.Vx3(m),data.Vy3(m),data.Vx3Std(m),data.Vy3Std(m),data.time(m)];
//[Status,He]=InstQD.GetPPMSItem(66,1,true);

//plot data linear
pause(0.01);

close(gcf);

subplot(19,2,[1,3,5,7]);
hold on; box on;
e=errorbar(IpulseList,data.Vx1,data.Vx1Std);
e=setErrorBar(e,'r');
xlim([min(Param.Ipulse) max(Param.Ipulse)]);
//title('Vx1');
//xlabel('Phase (deg)');
ylabel('Vx1 (V)');

subplot(19,2,[2,4,6,8]);
hold on; box on;
e=errorbar(IpulseList,data.Vy1,data.Vy1Std);
e=setErrorBar(e,'r');
xlim([min(Param.Ipulse) max(Param.Ipulse)]);
//title('Vy1');
//xlabel('Phase (deg)');
ylabel('Vy1 (V)');

subplot(19,2,[11,13,15,17]);
hold on; box on;
e=errorbar(IpulseList,data.Vx2,data.Vx2Std);
e=setErrorBar(e,'r');
xlim([min(Param.Ipulse) max(Param.Ipulse)]);
//title('Vx2');
//xlabel('Phase (deg)');
ylabel('Vx2 (V)');

subplot(19,2,[12,14,16,18]);
hold on; box on;
e=errorbar(IpulseList,data.Vy2,data.Vy2Std);
e=setErrorBar(e,'r');
xlim([min(Param.Ipulse) max(Param.Ipulse)]);
//title('Vy2');
//xlabel('Phase (deg)');
ylabel('Vy2 (V)');

subplot(19,2,[21,23,25,27]);
hold on; box on;
e=errorbar(IpulseList,data.Vx3,data.Vx3Std);
e=setErrorBar(e,'r');
xlim([min(Param.Ipulse) max(Param.Ipulse)]);
//title('Vx3');
ylabel('Vx3 (V)');

subplot(19,2,[22,24,26,28]);
hold on; box on;
e=errorbar(IpulseList,data.Vy3,data.Vy3Std);
e=setErrorBar(e,'r');
xlim([min(Param.Ipulse) max(Param.Ipulse)]);
//title('Vy3');
ylabel('Vy3 (V)');



subplot(7,2,[13,14]);
box on; box on; set(gca,'xtick',[]); set(gca,'ytick',[]);
//Msg = ['time=',num2str(data.time(m)),' min; B=',num2str(IpulseSetPoint/10000),' T; He=',num2str(round(He)),'//' ];
Msg = ['time=',num2str(data.time(m)),'Ipulse=',num2str(IpulseSetPoint),' A;' ];
t = text(0.20,0.5,Msg,'FontSize',14);


pause(0.01);

//char() is conversion function to str
//num2str() is conversion function from float to str
fileNameHeader = [char(time),Param.fileHeader,num2str(Param.Temp(TempIndex)),'K_',num2str(Param.Imax(CurrentIndex)*1e3),'mA_',num2str(Param.Ifrequency(FreqIndex)),'Hz_',num2str(Param.angle(AngleIndex)),'deg'];
//fileNameHeader = [char(time),Param.fileHeader,num2str(Param.Temp(TempIndex)),'K_',num2str(Param.Imax(CurrentIndex)*1e3),'mA_',num2str(Param.Ifrequency(FreqIndex)),'Hz_',num2str(Param.angle(AngleIndex)),'deg','SmallHstep',num2str(Param.Ipulsestart(TempIndex)*1e-4),'T-',num2str(Param.Ipulseend(TempIndex)*1e-4),'T_','Polling_OutOfPlane1T'];
//fileNameHeader = [char(time),Param.fileHeader,num2str(Param.Temp(TempIndex)),'K_',num2str(Param.Imax(CurrentIndex)*1e3),'mA_',num2str(Param.Ifrequency(FreqIndex)),'Hz_',num2str(Param.angle(AngleIndex)),'deg','SmallHstep',num2str(Param.Ipulsestart(TempIndex)*1e-4),'T-',num2str(Param.Ipulseend(TempIndex)*1e-4),'T_','Polling_OutOfPlane-1T'];

fileName=fullfile(pwd,Param.folder,[fileNameHeader,'.txt']);                     //make datafile title
dlmwrite(fileName,measurerecord0,'-append','delimiter',' ','precision',9);
pause(0.1);

m=m+1;

fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];


try
    fileNameJpg=fullfile(pwd,Param.folder,[fileNameHeader,'.jpg']);                     //make datafile title
    saveas(gcf, fileNameJpg);
    
    //fileNameFig=fullfile(pwd,Param.folder,[fileNameHeader,'.fig']);                     //make datafile title
    //saveas(gcf, fileNameFig);
end




function ErrorBar=setErrorBar(ErrorBar,Color)
E=ErrorBar;
E.Marker='o';
E.MarkerSize = 3;
E.MarkerEdgeColor = Color;
E.MarkerFaceColor = Color;
E.Color=Color;
E.LineWidth=1;