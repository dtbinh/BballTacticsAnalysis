function basketballArea = LoadBasketballCourtArea

%left, right are determined on facing basketball

basketballArea(1).name = 'leftBlock';
basketballArea(1).CenterPosition = [278,127];
basketballArea(1).FaceColor = [0 128 128];
basketballArea(2).name = 'rightBlock';
basketballArea(2).CenterPosition = [278,222];
basketballArea(2).FaceColor = [0 128 128];

basketballArea(3).name = 'leftElbow';
basketballArea(3).CenterPosition = [196,127];
basketballArea(3).FaceColor = [128 0 128];
basketballArea(4).name = 'rightElbow';
basketballArea(4).CenterPosition = [196,222];
basketballArea(4).FaceColor = [128 0 128];

basketballArea(5).name = 'topKey';
basketballArea(5).CenterPosition = [124 174];
basketballArea(5).FaceColor = [128 128 0];


basketballArea(6).name = 'leftWing';
basketballArea(6).CenterPosition = [196,41];
basketballArea(6).FaceColor = [128 0 0];
basketballArea(7).name = 'rightWing';
basketballArea(7).CenterPosition = [196,308];
basketballArea(7).FaceColor = [128 0 0];


basketballArea(8).name = 'leftCorner';
basketballArea(8).CenterPosition = [288,12];
basketballArea(8).FaceColor = [0 0 128];
basketballArea(9).name = 'rightCorner';
basketballArea(9).CenterPosition = [288,337];
basketballArea(9).FaceColor = [0 0 128];


basketballArea(10).name = 'leftShortCorner';
basketballArea(10).CenterPosition = [288,64];
basketballArea(10).FaceColor = [0 128 0];
basketballArea(11).name = 'rightShortCorner';
basketballArea(11).CenterPosition = [288,285];
basketballArea(11).FaceColor = [0 128 0];

basketballArea(12).name = 'leftLogo';
basketballArea(12).CenterPosition = [63,41];
basketballArea(12).FaceColor = [0 0 0];
basketballArea(13).name = 'rightLogo';
basketballArea(13).CenterPosition = [63,308];
basketballArea(13).FaceColor = [0 0 0];

% % plot basketball court region
% basketballArea = roi2court(halfCourt,basketballArea);

