function [] = helper(frame, violaBox, upperBox, lowerBox, points)
figure;
imshow(frame);
hold on;
rectangle('Position',upperBox, 'Edgecolor', 'blue');
hold on;
rectangle('Position',lowerBox, 'Edgecolor', 'blue');
hold on;
rectangle('Position',violaBox, 'Edgecolor', 'red');
hold on;
plot(points(:,1), points(:,2), 'g+');
end