function output = makeDerivativeOfTime(input,frameRate)

% input is fx2 signal
output = frameRate*(input(2:end,:)-input(1:end-1,:));

end
