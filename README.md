# Description
  ASDFTEslteKyotoCuda_mod.m calculates transfer entropy and sorted local transfer entropy to assess cell-cell interactions, taking into account a certain width of delay.
  Transfer entropy quantifies the directed causal coupling strengths among neurons.
  Sorted local transfer entropy is similar to the normal transfer entropy and specifically distinguishes between inhibitory influences
  and excitatory influences, by using a sorting method that takes into account the reversed signs of the local transfer entropies for
  the excitatory and inhibitory interactions. 
  ASDFTEslteKyotoCuda_mod.m running in matlab loads TransentPTXSLTEslte.cu and transentPTXSLTEslte.ptx. 
  Therefore, after compiling TransentPTXSLTEslte.cu with matlab, run ASDFTEslteKyotoCuda_mod.m with matlab.
  The CUDA code calculates only with a fixed delay, and ASDFTEslteKyotoCuda_mod.m calculates with multiple delays.

----------------    
# Requirments
    
  Matlab, CUDA and GPU are necessary to run this code.
  
-----------------
# Example data
  spike.mat
  
    a matlab data recording a neuronal spike squences.
    size of data: (1, N+2) (N is the number of neurons) 
    (1-N) components: spike data (time stamps of spike happened) 
    N+2 component: Number of cortical neurons and maximum time step  time bin size: 1ms  
  
----------------
# Example of usage

    load ./spike.mat
    delay0 = [1:30];
    [peakTE, sltecpp, TEdelays, measureddelay, CI, peakTE_all] = ASDFTEslteKyotoCuda_mod( spikes, delay0, 1);

----------------
# Inputs

        spikes: spike data (structure form), the last line express data size the second line from the last one is a blank.
                 
       j_delay: the used delays of post-synaptic neuron j ( default value is [1:30])        
       i_order: the order of pre-synaptic neuron i  ( default value is only [1])     this is not used in GPU version
       j_order: the order of pre-synaptic neuron j  ( default value is only [1])     this is not used in GPU version
    windowsize: window size to calculate CIs
----------------
# Outputs

          te-result : TE values at the peak delay
          sltecpp   : SLTE values (with delay)
          all_te    : TE values (with delay)
          delayindex: The delays when TE showed the peak
          ci_result : CI (Coincidence Index) values
      te_result_all : TE values in five miliseconds after their peakpoints    
-----------------
# Reference
   If you use this code, cite this following article: Kajiwara, M., Nomura, R., Goetze, F., Akutsu, T., & Shimono, M. (2020). Inhibitory neurons are a Central Controlling regulator in the effective cortical microconnectome. bioRxiv.
