function [f, P1, periodicity, pulse] = calculateSSAmplitudeSpectrum(si, frameRate, secs)
%This is adapted from the Matlab fft example
Fs = frameRate;            % Sampling frequency
L = Fs*secs;             % Length of signal

P2 = abs(si/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
[~, i] = max(P1);
pulse = 60/f(i);
periodicity = 0;
end