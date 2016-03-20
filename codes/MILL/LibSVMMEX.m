function  [Y_compute, Y_prob] = LibSVMMEX(para, X_train, Y_train, X_test, Y_test)
   
%global model accuracy

num_class = 2;
p = str2num(char(ParseParameter(para, {'-Kernel';'-KernelParam'; '-CostFactor'; '-NegativeWeight'; '-Threshold'}, {'2';'0.05';'1';'1';'0'})));

switch p(1)
    case 0
      s = '';      
    case 1
      s = sprintf('-d %.10g -g 1', p(2));
    case 2
      s = sprintf('-g %.10g', p(2));
    case 3
      s = sprintf('-r %.10g', p(2)); 
    case 4
      s = sprintf('-u "%s"', p(2));
end

libsvm_options = sprintf(['-b 1 -s 0 -t %d %s -c %f -w1 1 -w0 %f'], p(1), s, p(3), p(4));


model = svmtrain(double(Y_train'), X_train, libsvm_options);

[Y_compute, accuracy, Y_prob] = svmpredict(Y_test, X_test, model, '-b 1');

% check which Y_prob is fo Y_compute
threshold = 0.5;
Level  = Y_prob > threshold;
for i = 1:size(Y_prob,2)
    if isequal(Level(:,i), Y_compute)
        break
    else
        continue
    end
end
Y_prob = Y_prob(:,i);

end




