dataDir = './data';
vid = VideoReader([dataDir '/movie.mov']);
frameRate = vid.FrameRate;
secLength = 10;
targetHz = 250;

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
while hasFrame(vid) && index <= frameRate*secLength
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
[modeDistance, occurances] = mode(round(maxDistance));
if(occurances > 1)
    ind = find(maxDistance <= modeDistance);
    featurePoints = featurePoints(:,ind, :);    
end
figure;
plot(1:size(featurePoints,1), ...
    featurePoints(:,1:10:size(featurePoints, 2),2)', '-');
interpValues = 1:frameRate/targetHz:size(featurePoints,1);
interpolatedYValues = spline(1:size(featurePoints,1), ...
featurePoints(:,:,2)',interpValues);

%.75 - 5 Hz
[b,a] = butter(5, [.75 5]/(targetHz/2),'bandpass');
figure;
freqz(b,a);
dataOut = filter(b,a,interpolatedYValues);
%pca
coeff = pca(dataOut); 
%find most periodic eigen
%find peaks
%.75 - 3.3 Hz