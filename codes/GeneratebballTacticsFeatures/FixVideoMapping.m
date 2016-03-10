function Traj_fix = FixVideoMapping(Traj_origin,court)

[h w c] = size(court);

Traj_fix = Traj_origin;

for p = 1:size(Traj_origin,2)
    Traj_fix{80,p}(:,1) = Traj_origin{80,p}(:,1);
    Traj_fix{80,p}(:,2) = h-Traj_origin{80,p}(:,2)+1;
end


end