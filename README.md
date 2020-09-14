
#Input files

           spikes: spike data (structure form), the last line express data size 
                   the second line from the last one is a blank.
          j_delay: the used delays of post-synaptic neuron j ( default value is [1:30])        
          i_order: the -- order of pre-synaptic neuron i  ( default value
                           is only [1])     this is not used in GPU version
          j_order: the -- order of pre-synaptic neuron j  ( default value
                           is only [1])     this is not used in GPU version
       windowsize: window size to calculate CIs
----------------

#Output files

          te-result : TE values at the peak delay
          sltecpp   : SLTE values (with delay)
          all_te    : TE values (with delay)
          delayindex: The delays when TE showed the peak
          ci_result : CI (Coincidence Index) values
      te_result_all : TE values in five miliseconds after their peakpoints
----------------  



----------------
# example of usage
    load ./spikes
    delay0 = [1:30];    %   delay1 = delay0+1;
    [peakTE, sltecpp, TEdelays, measureddelay, CI, peakTE_all] = ASDFTEslteKyotoCuda_mod( spikes, delay0, 1);
    
    
  
