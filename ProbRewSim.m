   
vr.debugMode = true;
for i = 1:100000
    vr.rewCount = 0;
    for j = 1:4
        randRew = rand;
        if vr.rewCount == 0 && randRew >= 0.5
            vr.isReward = 1;
            if ~vr.debugMode
                putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
                start(vr.ao);
                stop(vr.ao);
            end
        elseif vr.rewCount == 0 && randRew < 0.5
            vr.isReward = 0.5;
        end
        if vr.rewCount == 1 && randRew >= 0.25
            if ~vr.debugMode
                pause(.04);
                putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
                start(vr.ao);
                stop(vr.ao);
            end
            vr.isReward = 1;
        elseif vr.rewCount == 1 && randRew < 0.25
            vr.isReward = 0.75;
        end
        if vr.rewCount >= 2
           if ~vr.debugMode     
                pause(.04);
                putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
                start(vr.ao);
                stop(vr.ao);
           end
            vr.isReward = 1;
        end
        vr.rewCount = vr.rewCount + 1;
        results(i,j) = vr.isReward;
    end
end
        