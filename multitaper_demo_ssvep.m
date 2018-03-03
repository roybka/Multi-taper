%***********************************************
%******* MULTITAPER EXAMPLE (with EEGLAB)  *****
%***********************************************
%********  Roy Amit, Oct. 2015  ****************
%***********************************************


clear;clc;close all

%%  important analysis parameters
padding=0; % zero padding, times the original length, 0=no padding
seg=[-.2 1]; % change second figure to see what happens with short data segments
bl=[-200 0];
chan=27; % We use O1
n_segments=1;% 0=all, change to see what happens with fewer data. 
samplingrate=1024; 
confi=0; % confidence interval calculation
nw=2; %time*halfbandwidth product 
%%
segmentations={{'5'},{'7'},{'8'},{'12'}}
frequencies={{'12'},{'17.333'},{'15'},{'10'}}
figure;
if samplingrate==128
dsname='ds3.set';
%dsname='ssvep_s1.set'
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename',dsname,'filepath',pwd);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );
EEG = pop_reref( EEG, 48);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 

EEG = pop_eegfiltnew(EEG, [], 0.2, 2112, true, [], 0);

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
EEG = eeg_checkset( EEG );
else 
  dsname='ds3_1024_filt.set';  
  [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename',dsname,'filepath',pwd);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

end

for i=1:4
fourier=[];
%get dataset:
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',1,'study',0); 
%epoch and segment:
EEG = pop_epoch( EEG, segmentations{i}, seg, 'newname', ['BDF file resampled epochs' segmentations{i}{1} ], 'epochinfo', 'yes');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, bl);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'overwrite','on','gui','off'); 
%reject artifacts (manual is better)
EEG = pop_eegthresh(EEG,1,27,-80,80,-0.10156,1.9922,0,1);
EEG = pop_rejepoch( EEG, find(EEG.reject.rejthresh),0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'overwrite','on','gui','off'); 
%extract data 
firstgoodsamp=ceil(EEG.srate/(1000/(abs(seg(1)*1000))));
chandata=EEG.data(chan,firstgoodsamp:end,:); %we dont want the baseline in the analysis...
chandata=squeeze(chandata);
fourier=[];
taper=[];
for k=1:size(chandata,2)      %of course it was accepted if you used fft directly on the matrix (fft(chandata)) 
    dat=chandata(:,k);
    if padding
    dat=[zeros(round(length(dat)*(padding-1)/2),1);dat;zeros(round(length(dat)*(padding-1)/2),1)];
    end
fourier(:,k)=fft(dat);
if ~confi
taper(:,k)=pmtm(dat,nw,length(dat),EEG.srate);
else
   [taper(:,k),f, ci(:,k)]=pmtm(dat,nw,length(dat),EEG.srate, 'ConfidenceLevel',.95)
end
end
fourier=fourier(1:round(length(fourier)/2),:); %take only the positive frequencies. 
%taper=taper(1:round(length(taper)/2),:); %take only the positive frequencies. 
fs=linspace(0,EEG.srate/2,length(fourier));
powerspec_f=abs(fourier);
powerspec_t=abs(taper);
% figure
% plot(fs,powerspec_f(:,randi(size(powerspec_f,2))))
% title(['One segment"s power spectrum for segmentation' segmentations{i}{1}])
% xlabel('frequency [hz] ')
% ylabel('POWER [sqrt(Volt)]')

if n_segments~=0
indexes=randperm(size(powerspec_f,2),n_segments);
else
    indexes=1:size(powerspec_f,2);
end
mean_power_s=mean(powerspec_f(:,indexes),2);

mean_power_s_t=mean(powerspec_t(:,indexes),2);
if length(mean_power_s_t)~=length(mean_power_s)
    
mean_power_s_t=mean_power_s_t(1:end-1);
end

firstind=find(fs>3,1,'first');
subplot(2,2,i);
plot(fs,mean_power_s./sum(mean_power_s))
hold on 
plot(fs,mean_power_s_t./sum(mean_power_s_t),'r')
ylim([0 max(mean_power_s_t(firstind:end)./sum(mean_power_s_t(firstind:end)))])
xlim([0 30])
title(['mean power spectrum for stimulus of ' frequencies{i}{1} ' hz'])
xlabel('frequency [hz] ')
ylabel('POWER [sqrt(Volt)]')
legend('FT','MT')
end

%%verbal answer
% it seems like trigger 12 is 10 hz
%               trigger 8 is 15 hz
%               trigger 7 is 17.33 hz
%               trigger 5 is 24 hz
% Answers using the log of the spectrum were also (definitely) accepted.
