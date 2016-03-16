function ROI = roi2court(halfCourt,ROI)

zone_num = length(ROI);

img = double(halfCourt);
y=zeros(size(img));

for i=1:zone_num

BW = poly2mask(ROI(i).CornerPosition(:,1),ROI(i).CornerPosition(:,2),size(halfCourt,1),size(halfCourt,2));
y= double(cat(3,BW,BW,BW))+y;
a = 0.5;
%z = false(size(BW));

z = false(size(BW));
mask = cat(3,BW,z,z); img(mask) = a*ROI(i).FaceColor(1) + (1-a)*img(mask);
mask = cat(3,z,BW,z); img(mask) = a*ROI(i).FaceColor(2) + (1-a)*img(mask);
mask = cat(3,z,z,BW); img(mask) = a*ROI(i).FaceColor(3) + (1-a)*img(mask);

ROI(i).BW = BW;
end
% % show result
% figure,imshow(uint8(img))
% F = getframe(gca);
% imwrite(F.cdata,'courtZone.png','png');
% %figure,imshow(y/2);

end