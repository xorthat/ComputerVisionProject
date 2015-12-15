clear;
close all;
dataDir = './data';
vid = VideoReader([dataDir '/movie2-68.mov']);
frameRate = vid.FrameRate;
secLength = 20;
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
s2 = dataOut'*V(:,2);
s3 = dataOut'*V(:,3);
s4 = dataOut'*V(:,4);
s5 = dataOut'*V(:,5);

pulse = calculatePulse(s1, s2, s3, s4, s5, frameRate)

