function [topBox, bottomBox, violaBox] = detectFaceTrackingPixels(frame)
violaJonesDetector = vision.CascadeObjectDetector;
bbox = step(violaJonesDetector, frame);
%if there are multiple faces, find the biggest one
if size(bbox, 2) > 1
    [~, ind] = max(bbox(:,3) .* bbox(:,4));
    bbox = bbox(ind, :);
    violaBox = bbox;
end

width = bbox(3);
height = bbox(4);
quarterWidth = round(width/4);
innerBox = [round(width/4)+bbox(1), bbox(2), quarterWidth*2, round(height*.9)];
topBox = [innerBox(1), innerBox(2), innerBox(3), round(height*.2)];
bottomBox =[innerBox(1), round(height*.55)+innerBox(2), innerBox(3), round(height*.2)];
end