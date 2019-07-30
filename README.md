# AIMD
This is a set of Matlab scripts that can plot MSD graph and calculate the diffusivity using XDATCAR files from VASP

# Author Lin Yuechuan 2019
Engineering Physics U of M
Mechanical Engineering Join Institute
# Compuatation Resource is received from Prof. Hong Zhu
# Partner: Ronghan Chen Zhenming Xu

# Orgnization of the files
In order to use the code to calculate the diffusion rate, 'XDATCAR' file from different runs should be saved in different folder with meaning full name and all the folder should be in a common folder. 
For example: \AIMD\1000k\XDATCAR
             \AIMD\1200k\XDATCAR
             \AIMD\1200k_2\XDATCAR

# Reform the data
Before we analyze the data, the XDATACAR should be reformed. Run 'xdatcar-xyz.py' inside the folder of each run.

# GET MSD
To get the MSD data and plot, run the 'MSDLi' inside the folder of each run. This script takes long time to finish becasue the data is very large. When it finshes, A plot smooth plot (MSD plot) and a rough plot (Origin started squared distance plot) will be generated. The result of this calculation is stored in 'TMSD.mat'.
Before we move on, you need to specify which time period you wish the code to fit. You should creat a vector called 'fitrange' and give two values which are the starting step and the end step which are directly related with time by the time step. Then save this vector as 'fitrange.mat' 
For example, you want to fit from 1000 fs to 10000 fs and the time step is 2 fs. The start step is 1000fs/2fs=500 and the end step is 10000fs/2fs=50000. Then you create a vector 
                    fitrange=[500 5000];
Save it
                    save 'fitrange.mat' fitrange 

# GET activation energy, D_0, D_300, using ResultMSD
Now, you should change the directory to the folder that contains folder of different runs. The input argument of ResltMSD function is 
function [D_0,E_a,Conductivity,D_300]=ResultMSD(N,q,d,dt,a,varargin)
N is the number of mobile Lithium ions, q is the charge of lithum ions in Coulomb, d is the dimension of the diffusion, dt is the time step in AIMD calculation in fs, a is the average site distance of lithium ion in Angstorm
varargin allows you to input the folder name and temperature (K) in the following fashion '1000data',1000,'1200_1',1200,'1200_2',1200,'1400',1400...
This function generates plot for MSD with linear fit for each run and use the diffusion rate and time to fit the Arrhenius relation of log10(D) as a function of 1000/T. The statistic variance of the results applies the Mo's method. The reuslts are written in 'result.txt'.
