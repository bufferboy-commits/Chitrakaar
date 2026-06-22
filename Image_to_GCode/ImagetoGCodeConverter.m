clc
clear
close all

%% 1. Read image
img = imread('D:\Downloads\House.png');
gray = im2gray(img);

%% 2. Binary (detect drawing)
bw = gray < 128;

figure
imshow(bw)
title('Binary Image')

%% 3. Manual edge detection 
edges = false(size(bw));

for i = 2:size(bw,1)-1
    for j = 2:size(bw,2)-1
        if bw(i,j) == 1
            if sum(sum(bw(i-1:i+1, j-1:j+1))) < 9
                edges(i,j) = 1;
            end
        end
    end
end

figure
imshow(edges)
title('Detected Edges')

%% 4. Get coordinates
[y, x] = find(edges);
points = [x y];

%% 5. ORDER points (path generation)
ordered = zeros(size(points));
ordered(1,:) = points(1,:);
points(1,:) = [];

for i = 2:size(ordered,1)
    
    last = ordered(i-1,:);
    d = sum((points - last).^2, 2);
    
    [~, idx] = min(d);
    
    ordered(i,:) = points(idx,:);
    points(idx,:) = [];
    
    if isempty(points)
        break
    end
end

x = ordered(:,1);
y = ordered(:,2);

%% 6. Reduce points (speed control)
step = 3;
x = x(1:step:end);
y = y(1:step:end);

%% 7. Scale
scale = 0.08;
x = x * scale;
y = y * scale;

%% 8. PEN SIMULATION (WITH LIFTING)

figure
axis equal
grid on
hold on
title('2D Printer Simulation')
xlabel('X')
ylabel('Y')

pen = plot(x(1), -y(1), 'ro','MarkerFaceColor','r');
path = plot(x(1), -y(1), 'b','LineWidth',2);

pathX = x(1);
pathY = -y(1);

for i = 2:length(x)
    
    dist = sqrt((x(i)-x(i-1))^2 + (y(i)-y(i-1))^2);
    
    % move pen
    set(pen,'XData',x(i),'YData',-y(i));
    
    if dist <= 2
        % Pen DOWN → keep adding to SAME path
        pathX = [pathX x(i)];
        pathY = [pathY -y(i)];
        
        set(path,'XData',pathX,'YData',pathY);
    end
    
    drawnow
end
%% 9. G-code generation

file = fopen('House_Sample.gcode3','w');

fprintf(file,'G21\n');      % mm
fprintf(file,'G90\n');      % absolute
fprintf(file,'G1 F1000\n'); % feed rate

for i = 2:length(x)
    dist = sqrt((x(i)-x(i-1))^2 + (y(i)-y(i-1))^2);
    if dist > 2
        fprintf(file,'M5\n');               % Pen UP
        fprintf(file,'G0 X%.2f Y%.2f\n', x(i), -y(i));
        fprintf(file,'M3\n');               % Pen DOWN
    else
        fprintf(file,'G1 X%.2f Y%.2f\n', x(i), -y(i));
    end
end

fprintf(file,'M2\n');
fclose(file);

disp('FINAL G-code generated.')
