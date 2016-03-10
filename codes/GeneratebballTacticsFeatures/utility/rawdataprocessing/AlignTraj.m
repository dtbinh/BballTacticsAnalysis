function outputTraj = AlignTraj(inputTraj,alignmentIndex)

for T = 1:size(inputTraj,1)
    display(['Tactic ' int2str(T) ':' ]);
    for p = 1:size(inputTraj,2)
        display([int2str(p) '->' int2str(alignmentIndex(T,p))]);
        outputTraj{T,p} = inputTraj{T,alignmentIndex(T,p)};
    end
end


end