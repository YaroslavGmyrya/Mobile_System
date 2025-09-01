
%variables
step = 0.001;
t = 0:step:2-step;
f = 4;

%signal
y = sin(12*pi*f*t+pi/11) + sin(10*pi*f*t);

%create and show plot
figure;
plot(t, y);
xlabel('t') 
ylabel('A')
title('Signal')
grid on

%sampling
Fs = 20;
t = 0:1/Fs:1-(1/Fs);

samples = zeros(1, length(t));

for k = 1:length(t)
    samples(k) = 50 * (sin(12*pi*f*t(k)+pi/11) + sin(10*pi*f*t(k)));
end

%DFT
F = fft(samples); 

%create plot with samples
figure;
plot(t, samples);
xlabel('t') 
ylabel('A')
title('Signal')

grid on

%create spectrum plot with samples
figure;
plot(abs(F));
xlabel('f') 
ylabel('A')
title('Signal')

%Test ADC capacity
for ADC_capacity = 3:6
    max_value = 2^ADC_capacity - 1;
    
    samples = zeros(1, length(t));
    
    for k = 1:length(t)
        tmp = 50 * (sin(12*pi*f*t(k)+pi/11) + sin(10*pi*f*t(k)));
        if tmp > max_value
            samples(k) = max_value;
        else
            samples(k) = tmp;
        end
    end

    F = fft(samples);

    figure;
    plot(abs(F));
    xlabel('f'); 
    ylabel('A');
    label = sprintf("Signal ADC_capacity = %d", ADC_capacity);
    title(label);
end





