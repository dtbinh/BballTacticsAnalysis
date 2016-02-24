function sIndex = transformPositionToCourtIndex(S,basketballZone,halfCourt)

[h w c] = size(halfCourt);


if iscell(S)
   [T P] = size(S);
   for t=1:T
       for p=1:P
           %tic
           for i=1:size(S{t,p},1)
               map = zeros(h,w);
               pp = round(S{t,p}(i,:));
               pp(1) = max(1,pp(1));
               pp(1) = min(pp(1),w);
               pp(2) = max(1,pp(2));
               pp(2) = min(pp(2),h);
               map(pp(2),pp(1)) = 1;
               hit = 0;
               for k = 1:length(basketballZone)
                   HitMap = and(map,basketballZone(k).BW);
                   hit = hit+sum(sum(HitMap));
                   disp(num2str([t,p,i,k,size(basketballZone(k).BW),size(map),pp]))
                   if hit
                       sIndex{t,p}(i,k) = 1;
                       hit = 0;
                   else
                       sIndex{t,p}(i,k) = 0;
                       continue
                   end
                   clear HitMap
               end
           end
           %toc
           %pause(0.5)
       end
   end
                   
    
end

end