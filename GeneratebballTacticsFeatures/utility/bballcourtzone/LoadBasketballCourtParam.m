function basketballZone = LoadBasketballCourtParam(halfCourt)


basketballZone(1).name = 'rightCornerThree';
basketballZone(1).CornerPosition = [230,0;326,0;326,23;230,23];
basketballZone(1).FaceColor = [0 128 128];
basketballZone(2).name = 'leftCornerThree';
basketballZone(2).CornerPosition = [230,327;326,327;326,348;230,348];
basketballZone(2).FaceColor = [0 128 128];

basketballZone(3).name = 'rightBaseLine';
basketballZone(3).CornerPosition = [270,23;326,23;326,120;270,120];
basketballZone(3).FaceColor = [128 0 128];
basketballZone(4).name = 'leftBaseLine';
basketballZone(4).CornerPosition = [270,230;326,230;326,327;270,327];
basketballZone(4).FaceColor = [128 0 128];

basketballZone(5).name = 'Paint';
basketballZone(5).CornerPosition = [195,120;326,120;326,230;195,230];
basketballZone(5).FaceColor = [128 128 0];

% basketballZone(5).name = 'rightRestrict';
% basketballZone(5).CornerPosition = [270,120;326,120;326,174;270,174];
% basketballZone(5).FaceColor = [128 128 0];
% basketballZone(6).name = 'leftRestrict';
% basketballZone(6).CornerPosition = [270,174;326,174;326,230;270,230];
% basketballZone(6).FaceColor = [0 128 0];

basketballZone(6).name = 'rightWingInside';
basketballZone(6).CornerPosition = [230,23;270,23;270,120;134,120];
basketballZone(6).FaceColor = [128 0 0];
basketballZone(7).name = 'leftWingInside';
basketballZone(7).CornerPosition = [134,230;270,230;270,327;230,327];
basketballZone(7).FaceColor = [128 0 0];



% basketballZone(9).name = 'rightPaint';
% basketballZone(9).CornerPosition = [195,120;270,120;270,174;195,174];
% basketballZone(9).FaceColor = [0 128 0];
% basketballZone(10).name = 'leftPaint';
% basketballZone(10).CornerPosition = [195,174;270,174;270,230;195,230];
% basketballZone(10).FaceColor = [128 128 0];

basketballZone(8).name = 'topKey';
basketballZone(8).CornerPosition = [134,120;195,120;195,230;134,230];
basketballZone(8).FaceColor = [0 0 128];

basketballZone(9).name = 'rightThree';
basketballZone(9).CornerPosition = [0,0;230,0;230,23;134,120;0,120];
basketballZone(9).FaceColor = [0 128 0];
basketballZone(10).name = 'topThree';
basketballZone(10).CornerPosition = [0,120;134,120;134,230;0,230];
basketballZone(10).FaceColor = [128 0 128];
basketballZone(11).name = 'leftThree';
basketballZone(11).CornerPosition = [0,230;134,230;230,327;230,348;0,348];
basketballZone(11).FaceColor = [0 128 0];


basketballZone = roi2court(halfCourt,basketballZone);
