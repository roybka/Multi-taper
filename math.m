
%% math behind tapers demo 
% show the fft of the tapers:
%show spectra of different tapers, their demodulation, and the comparison
%between spectra of 1st taper with different 'nw's. 
T=1;
sr=1000;
dt=1/sr;
timeline=dt:dt:T;
nw=3;
a=dpss(T*sr,nw);
b=a(:,1);
y=fft(b);
figure;
subplot(2,1,1)
title('taper')
plot(b);
subplot(2,1,2)
plot(abs(y))
title('fft(taper)')
xlim([0 100])

%% moving the taper to a chosen frequency f0
f0=20;

b=a(:,2).*exp(2*pi*i*f0*t');
y=fft(b);
plot(abs(y));
