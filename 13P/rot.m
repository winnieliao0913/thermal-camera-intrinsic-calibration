function [xRot, yRot] = rot(x,y,ang)
%% Rotate x and y by angle ang (in degrees)
% rotate in the counter-clockwise direction
if length(ang) == 2
    rotAngle = -atan(ang(2)/ang(1));
else
    rotAngle = ang;
end

xRot     = x.*cosd(rotAngle) - y.*sind(rotAngle);
yRot     = x.*sind(rotAngle) + y.*cosd(rotAngle);