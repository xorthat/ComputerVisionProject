function [pulse] = calculatePulse(s1, s2, s3, s4, s5, frameRate)
                    
p = zeros(5,1);
maxFreq = zeros(5,1);
[p(1), maxFreq(1)] = calculatePeriodocityAndMaxFreq(s1, frameRate);
[p(2), maxFreq(2)] = calculatePeriodocityAndMaxFreq(s2, frameRate);
[p(3), maxFreq(3)] = calculatePeriodocityAndMaxFreq(s3, frameRate);
[p(4), maxFreq(4)] = calculatePeriodocityAndMaxFreq(s4, frameRate);
[p(5), maxFreq(5)] = calculatePeriodocityAndMaxFreq(s5, frameRate);

[~, i] = max(p);
pulse = 60*maxFreq(i);
end