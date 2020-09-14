
function [te_result,sltecpp, all_te, delayindex,ci_result, te_result_all] = ASDFTEslteKyotoCuda_mod(spikes, j_delay, i_order, j_order, windowsize)   %% TERMWISE
% function [te_result, te_termwise] = ASDFTE(spikes, j_delay, i_order, j_order, windowsize)
% 
% [Inputs]
%           spikes: spike data (structure form), the last line express data size 
%                   the second line from the last one is a blank.
%          j_delay: the used delays of post-synaptic neuron j ( default value is [1:30])        
%          i_order: the -- order of pre-synaptic neuron i  ( default value
%                           is only [1])     this is not used in GPU version
%          j_order: the -- order of pre-synaptic neuron j  ( default value
%                           is only [1])     this is not used in GPU version
%       windowsize: window size to calculate CIs
%  
% [Outpts]
%          te-result : TE values at the peak delay
%          sltecpp   : SLTE values (with delay)
%          all_te    : TE values (with delay)
%          delayindex: The delays when TE showed the peak
%          ci_result : CI (Coincidence Index) values
%      te_result_all : TE values in five miliseconds after their peakpoints
%          
%              written by Felix Goetz   2018
% modified and cleaned by Motoki Kajiwara  2020

if nargin < 2
    j_delay = 1;
end

if nargin < 3
    i_order = 1;
end

if nargin < 4
    j_order = 1;
end

if nargin < 5
    windowsize = 5;
end

% Multiple delays
num_delays = length(j_delay);
info = spikes{end};
num_neurons = info(1);

% Allocate space for all matrices
all_te = zeros(num_neurons, num_neurons, num_delays);
sltecpp = zeros(num_neurons, num_neurons, num_delays);

% GPU version
k = parallel.gpu.CUDAKernel('transentPTXSLTEslte.ptx','transentPTXSLTEslte.cu','transent_1');
time = spikes{end}(2);
neurons = spikes{end}(1);
N = neurons*neurons;
k.ThreadBlockSize = 1024;
k.GridSize =  65000;
darray = [spikes{1:length(spikes)-2}];
lengths = ones(neurons,1);
pos = zeros(neurons,1);
duration = gpuArray(time); % length of simulation   duration
te_result = zeros(N,1,'gpuArray'); % 10000          te_result
slte_result = zeros(N,1,'gpuArray'); % 10000          slte_result
rule = [+1, -1, +1, -1, -1, +1,-1, +1];
rulegpu = gpuArray(rule);
for i = 1:neurons
    lengths(i) = length(spikes{i});
    if i > 1
        pos(i) = pos(i-1) + lengths(i-1);
    end
end
all_series = gpuArray(darray); % all_series in one array      all_series
positions = gpuArray(int32(pos)); % positions of starting points of series      positions
lengthsgpu = gpuArray(lengths); % lengths of each series      lengths
series_count = gpuArray(neurons); %

for d = 1:num_delays % Change this for to parfor for parallelization. parfor
    y_delay = gpuArray(d); % time lag     y_delay
    
    % GPU version
    [all_teGPU,sltecppGPU] = feval(k,te_result,slte_result,all_series,positions,lengthsgpu,series_count,y_delay,duration,rulegpu);
    wait(gpuDevice);
    
    all_te(:, :, d) = reshape(gather(all_teGPU), [neurons, neurons]);
    sltecpp(:,:,d) = reshape(gather(sltecppGPU), [neurons, neurons]);
    
end % if multiple delays

% Reduce to final matrix
[te_result, delayindex] = max(all_te, [], 3); % reduction in 3rd dimension

for ii1 = 1:size(all_te,1)
    for ii2 = 1:size(all_te,2)
        if delayindex(ii1,ii2) == 1
            te_result_all(ii1,ii2,:) = all_te( ii1, ii2, [delayindex(ii1,ii2) : delayindex(ii1,ii2) + 4]);
        elseif delayindex(ii1,ii2) >= max( j_delay) - 4
            te_result_all(ii1,ii2,:) = all_te( ii1, ii2, [delayindex(ii1,ii2)-4 : delayindex(ii1,ii2)]);
        else
            te_result_all(ii1,ii2,:) = all_te( ii1, ii2, [delayindex(ii1,ii2)-1 : delayindex(ii1,ii2) + 3]);
        end
    end
end

size(delayindex)

ci_result = zeros(num_neurons);
if nargout > 1
    for i = 1:num_neurons
        for j = 1:num_neurons
            ci_result(i, j) = CIReduce(all_te(i, j, :), windowsize);
        end
    end
end

