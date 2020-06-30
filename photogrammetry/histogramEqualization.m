%   image - image unique value and count repeater. [60, 60] image etc.
%   grayscale - gray level scale. [0 9], etc.
%   repeater - repeating on histogram. [50 100 150 30 160 ...] etc.
function [out] = histogramEqualization(varargin)
input.image = [] ;
input.grayscale = [] ;
input.repeater = [] ;
input.percentofcumulative = [] ;
for count = 1 : 2 : length(varargin)
    if mod(length(varargin), 2)
        varargin(end) = [] ;
    end
    input.(varargin{count}) = varargin{count + 1} ;
end
grayvalue = input.grayscale(1) : input.grayscale(2) ;
input.gray = zeros(1, input.grayscale(2) + 1) ;
if ~isempty(input.image)
    for count = min(grayvalue) +1 : max(grayvalue) + 1
        input.repeater(count) = numel(find(input.image == grayvalue(count)));
    end
end
percent = round(input.repeater ./ sum(input.repeater), 4) ;
cumulative = 0;
for i = min(grayvalue) +1 : max(grayvalue) + 1
    cumulative = cumulative + percent(i) ;
    input.percentofcumulative(i) = round(cumulative, 2) ;
end
T = round(grayvalue ./ input.grayscale(2), 2) ;

for cumulat = min(grayvalue) +1 : max(grayvalue) + 1
    for gray = min(grayvalue) +1 : max(grayvalue) 
        if input.percentofcumulative(cumulat) >= T(gray) && input.percentofcumulative(cumulat) <= T(gray + 1)
            low = abs(input.percentofcumulative(cumulat) - T(gray)) ;
            up = abs(input.percentofcumulative(cumulat) - T(gray + 1)) ;
            if low <= up
                input.gray(gray) =  input.repeater(cumulat) + input.gray(gray) ;
                break;
            elseif low >= up
                input.gray(gray + 1) =  input.repeater(cumulat) + input.gray(gray + 1) ;
                break;
            end
        end
    end
end
out.repeat = input.repeater ;
out.percent = percent ;
out.cumulative = input.percentofcumulative  ;
out.gray = input.gray ;
fprintf('Gray  Repeat\t%%\t Cum%%   T\tGrayScale\n')
fprintf('%d\t%d\t%.4f\t   %.2f\t  %.2f\t%d\n', [grayvalue; input.repeater; percent; input.percentofcumulative; T; input.gray]) ;
end