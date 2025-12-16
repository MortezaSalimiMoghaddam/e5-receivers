load('codes_E5aI.mat');
x= x(1:5:end);
for i = 1:length(x)-10500
    sig = x(i:i+10229);
    corrres(i) = sum(sig.*codes_E5aI(:,2));
end