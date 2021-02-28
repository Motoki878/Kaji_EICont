# Description
  ASDFTEslteKyotoCuda_mod.m calculates transfer entropy and sorted local transfer entropy to assess neuron-neuron interactions, taking into account a certain width of delay.
  Transfer entropy quantifies the directed causal coupling strengths among neurons.
  Sorted local transfer entropy is similar to the normal transfer entropy and specifically distinguishes between inhibitory influences
  and excitatory influences, by using a sorting method that takes into account the reversed signs of the local transfer entropies for
  the excitatory and inhibitory interactions. 
  ASDFTEslteKyotoCuda_mod.m running in matlab loads TransentPTXSLTEslte.cu and transentPTXSLTEslte.ptx. 
  Therefore, after compiling TransentPTXSLTEslte.cu with matlab, run ASDFTEslteKyotoCuda_mod.m with matlab.
  The CUDA code calculates only with a fixed delay, and ASDFTEslteKyotoCuda_mod.m calculates with multiple delays.
  The GPU code will be 10-100 times faster than other CPU codes.

----------------    
# Requirments
    
  Matlab, CUDA and GPU are necessary to run this code.
  You need to prepare a basic compiler environment for CUDA code.
  For example, refer https://jp.mathworks.com/help/parallel-computing/mexcuda.html
  
-----------------
# Example data
  spike.mat
  
    a matlab data recording a neuronal spike squences.
    size of data: (1, N+2) (N is the number of neurons) 
    (1-N) components: spike data (time stamps of spike happened) 
    N+2 component: Number of cortical neurons and maximum time step  time bin size: 1ms  
    
-----------------
# Setting
    mexcuda ./TransentPTXSLTEslte.cu
  
----------------
# Example of usage
    load ./spike.mat
    delay0 = [1:30];
    [peakTE, SLTEdelays, TEdelays, delayindex, CI, peakTE_all] = ASDFTEslteKyotoCuda_mod( spikes, delay0, 1);

----------------
# Inputs of the main code (ASDFTEslteKyotoCuda_mod)
        spikes : spike data (structure form), the last line express data size the second line from the last one is a blank.
       delay0  : the used delays of post-synaptic neuron j ( default value is 1-30 [ms]).
       
----------------
# Outputs of the main code (ASDFTEslteKyotoCuda_mod)
          TEdelays   : TE (Transfer Entropy) values depending with delay (1-30ms) between a spike of pre-synaptic neuron and spikes of post-synaptic neurons.
          SLTEdelays : SLTE (Sorted Local Transfer Entropy) values depending with delay (1-30ms) between a spike of pre-synaptic neuron and spikes of post-synaptic neurons.
          peakTE     : TE (Transfer Entropy) values at the peak  (maximum) point of the previously given variable, TEdelays.
          delayindex : The bin index at the delay when TE showed the peak (maximum) value.
          ci_result  : CI (Coincidence Index) values calculated from the TEdelays. 
          peakTE_all : TE values only within five bins after their peak points.
-----------------
# Reference
   If you use this code, cite this following article: 
   
   Kajiwara, M., Nomura, R., Goetze, F., Akutsu, T., & Shimono, M. (2020). Inhibitory neurons are a Central Controlling regulator in the effective cortical microconnectome. under review.
