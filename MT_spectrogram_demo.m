elec=27;
win=[.4,.01];
t=win(1)*EEG.srate;
w=3/EEG.srate;
data=squeeze(EEG.data(elec,:,:));

params.tapers=[w*t,3]; %WT, K 
params.Fs=EEG.srate;
params.trialave=1;
params.fpass=[5 60];



[S,t,f]=mtspecgramc(data,win,params);
figure;
plot_matrix(S,t,f)