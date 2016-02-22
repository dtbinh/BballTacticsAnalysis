function output = makeDerivativeOfTime(input)

% input is fx2 signal
output = input(2:end,:)-input(1:end-1,:);

end
