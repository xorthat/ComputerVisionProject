clear;
close all;
dataDir = './data';
vid = VideoReader([dataDir '/movie2.mov']);
frameRate = vid.FrameRate;
secLength = 10;
targetHz = frameRate;
earlyInd = 1;

while hasFrame(vid) && earlyInd <= frameRate
    video = readFrame(vid);
    earlyInd = earlyInd + 1;
end

% firstFrame
frame = readFrame(vid);
frame = im2double(frame);
grayframe = rgb2gray(frame);
[topBox, bottomBox, violaBox] = detectFaceTrackingPixels(frame);
featurePointsTop = detectMinEigenFeatures(grayframe, 'ROI', topBox);
featurePointsBottom = detectMinEigenFeatures(grayframe, 'ROI', bottomBox);
kltTracker = vision.PointTracker();
points = [featurePointsTop.Location; featurePointsBottom.Location];
initialize(kltTracker, points, frame)
helper(frame, violaBox, topBox, bottomBox, points)
index = 2;
featurePoints = zeros(floor(frameRate*secLength),size(points,1), size(points,2)); 
featurePoints(1,:,:) = points;

while hasFrame(vid) && index <= frameRate*secLength+1
    frame = readFrame(vid);
    frame = im2double(frame);
    [points,point_validity] = step(kltTracker,frame);
    featurePoints(index,:,:) = points .*...
        repmat(point_validity,1,size(points,2));
    index = index + 1;
end
distance = sqrt((featurePoints(1:end-1,:,1)-featurePoints(2:end,:,1)).^2 ...
+ (featurePoints(1:end-1,:,2)-featurePoints(2:end,:,2)).^2);
maxDistance = max(distance, [], 1);
[modeDistance, occurances] = mode(ceil(maxDistance));
if(occurances > 1)
    ind = find(maxDistance <= modeDistance);
    featurePoints = featurePoints(:,ind, :);    
end
% figure;
% plot(1:size(featurePoints,1), ...
%     featurePoints(:,1:10:size(featurePoints, 2),2)', '-');
% interpValues = 1:frameRate/targetHz:size(featurePoints,1);
%  interpolatedYValues = spline(1:size(featurePoints,1), ...
%  featurePoints(:,:,2)',interpValues);
interpolatedYValues = featurePoints(:,:,2); %TxN
%.75 - 5 Hz
[b,a] = butter(5, [.75 
    5]/(targetHz/2),'bandpass');
% figure;
% freqz(b,a);
dataOut = filter(b,a,interpolatedYValues);
%pca
dataOut = dataOut';
N = size(dataOut,1);
T = size(dataOut,2);
l2 = zeros(T,1);
for i = 1:T
    l2(i) = norm(dataOut(:,i),2);
end
[values, ind] = sort(l2, 'descend');
cutoffPercentage = .25;
ind = ind(round(N*cutoffPercentage):end);
meanY = mean(dataOut(:,ind),2);
covarY = 1/T.*(dataOut(:,ind)-repmat(meanY,1,numel(ind)))*...
    (dataOut(:,ind)-repmat(meanY,1,numel(ind)))';
[V,D] = eig(covarY);

s1 = dataOut'*V(:,1);
[pxx,f] = periodogram(s1,[],[], frameRate);
[y,i] = max(pxx);
pulse1 = 60 / f(i);
% [f, P1_1, periodicity, pulse1] = calculateSSAmplitudeSpectrum(s1, frameRate, secLength);

s2 = dataOut'*V(:,2);
[pxx,f] = periodogram(s2,[],[], frameRate);
[y,i] = max(pxx);
pulse2 = 60 / f(i);
% [f, P1_2, periodicity, pulse2] = calculateSSAmplitudeSpectrum(s2, frameRate, secLength);
 
s3 = dataOut'*V(:,3);
[pxx,f] = periodogram(s3,[],[], frameRate);
[y,i] = max(pxx);
pulse3 = 60 / f(i);
% [f, P1_3, periodicity, pulse3] = calculateSSAmplitudeSpectrum(s3, frameRate, secLength);

s4 = dataOut'*V(:,4);
[pxx,f] = periodogram(s4,[],[], frameRate);
[y,i] = max(pxx);
pulse4 = 60 / f(i);
% [f, P1_4, periodicity, pulse4] = calculateSSAmplitudeSpectrum(s4, frameRate, secLength);

s5 = dataOut'*V(:,5);
[pxx,f] = periodogram(s5,[],[], frameRate);
[y,i] = max(pxx);
pulse5 = 60 / f(i);
% [f, P1_1, periodicity, pulse1] = calculateSSAmplitudeSpectrum(s1, frameRate, secLength);[f, P1_5, periodicity, pulse5] = calculateSSAmplitudeSpectrum(s5, frameRate, secLength);