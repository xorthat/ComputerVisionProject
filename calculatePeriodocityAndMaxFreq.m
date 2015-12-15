function [periodocity, maxFreq] = calculatePeriodocityAndMaxFreq(signal, Fs)
%This is adapted from the Matlab fft example
L = numel(signal);
power = abs(fft(signal).^2);
power = power(1:L/2+1);
power(2:end-1) = 2*power(2:end-1);
f = Fs*(0:(L/2))/L;
[maxAmp, index] = max(power);
maxFreq = f(index);
periodocity = (maxAmp + power(index*2)) / sum(power);
end