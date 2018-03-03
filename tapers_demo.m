%% comparson of MT and normal spectral estimates with different noise colors. 
% Roy Amit oct. 2015/ 

clear;clc;close all

sr=1000;
dt=1/sr;
seglen=3;% in seconds
timeline=0:dt:seglen;
T=length(timeline)/sr;
f1=10;f2=19;



%% fft of clean signal 
x=sin(2*pi*f1*timeline);
y=fft(x);
y=abs(y(1:round(length(y)/2)));
fs=linspace(0,sr/2,length(y));
figure;set(gcf, 'Position', get(0,'Screensize'));
subplot(2,1,1)
plot(timeline,x)
subplot(2,1,2)
plot(fs,y)
%% with hamming
x=sin(2*pi*f1*timeline);
y=fft(x.*hamming(1,length(x)));
y=abs(y(1:round(length(y)/2)));
fs=linspace(0,sr/2,length(y));
figure;set(gcf, 'Position', get(0,'Screensize'));
subplot(2,1,1)
plot(timeline,x.*hamming(length(x)))
subplot(2,1,2)
plot(fs,y)
%% fft of noisy signal 
noisefactor=8; %8
x=sin(2*pi*f1*timeline)+randn(1,length(timeline))*noisefactor;
y=fft(x);
y=abs(y(1:round(length(y)/2)));
fs=linspace(0,sr/2,length(y));
figure;set(gcf, 'Position', get(0,'Screensize'));
plot(fs,y)

xlim([0 80])

%% now multitaper
noisefactor=8; %8
nw=3;% time-halfband product ( number of tapers will be nw*2-1 (**) 
w=1; % resolution in number of raleigh freqs (smoothing parameter)
nw=T*w;
x=sin(2*pi*f1*timeline)+randn(1,length(timeline))*noisefactor;%-noisefactor/2;
y=pmtm(x,nw,length(x),sr);
fs=linspace(0,sr/2,length(y));
figure;set(gcf, 'Position', get(0,'Screensize'));
plot(fs,y)
xlim([0 80])
%% now both, compared 10 times with random gaussian noises
% show different 'nw's
clear;clc;close all
figure;set(gcf, 'Position', get(0,'Screensize'));
f1=10;f2=19;
noisefactor=8;
sr=1000;
padding=4;
dt=1/sr;
%nw=3;
seglen=3;% in seconds
timeline=0:dt:seglen;
T=length(timeline)/sr;
w=3;
nw=T*w;
for i=1:10
    subplot(2,5,i)
    x=sin(2*pi*f1*timeline)+randn(1,length(timeline))*noisefactor;
    if padding
        x=[zeros(1,length(x)*(padding*.5)) ,x ,zeros(1,length(x)*(padding*.5))];
    end
    y_taper=pmtm(x,nw,length(x),sr);
    y_taper=abs(y_taper);%(1:round(length(y_taper)/2)));
    fs=linspace(0,sr/2,length(y_taper));
    y_fft=fft(x);
    y_fft=abs(y_fft(1:round(length(y_fft)/2)));
    subplot(2,5,i)
    plot(fs,y_fft./sum(y_fft),fs,y_taper./sum(y_taper));
    xlim([0 50])
    legend('fourier','taper')
end


    
    %% same, with pink noise
clear;clc;close all
addpath('C:\Users\IBM\Documents\MATLAB\noise generation')
figure;set(gcf, 'Position', get(0,'Screensize'));
f1=19;f2=10;
noisefactor=4;
sr=1000;
dt=1/sr;
%nw=3;
padding=4;
seglen=3;% in seconds
timeline=0:dt:seglen;
T=length(timeline)/sr;
w=2;
nw=T*w;
disp(nw*2-1)
for i=1:10
    subplot(2,5,i)
    x=sin(2*pi*f1*timeline)+(pinknoise(length(timeline)))*noisefactor;
    if padding
        x=[zeros(1,length(x)*(padding*.5)) ,x ,zeros(1,length(x)*(padding*.5))];
    end
    y_taper=pmtm(x,nw,length(x),sr);
    y_taper=abs(y_taper);%(1:round(length(y_taper)/2)));
    fs=linspace(0,sr/2,length(y_taper));
    y_fft=fft(x);
    y_fft=abs(y_fft(1:round(length(y_fft)/2)));
    subplot(2,5,i)
    plot(fs,y_fft./sum(y_fft),fs,y_taper./sum(y_taper));
    xlim([0 50])
    legend('fourier','taper')
end
    
    
