

----------------


----------------  



----------------
# example of usage
    load ./spikes
    delay0 = [1:30];    %   delay1 = delay0+1;
    [peakTE, sltecpp, TEdelays, measureddelay, CI, peakTE_all] = ASDFTEslteKyotoCuda_mod( spikes, delay0, 1);
  