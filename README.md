# MATLAB-NS3
Co-simulate MATLAB with NS-3 network simulator, combining the powers of MATLAB and NS-3. Describe the scenario in MATLAB, run simulation from MATLAB, capture the results and visualize them in MATLAB.
Optionally use the MATLAB PHY and Channel models, instead of the statistical models of NS-3.

This co-simulation code currently:
   * Supports modeling WLAN network and 802.11p based V2X scenarios.
      *	See the documentation for the list of supported classes.
   * Works with NS3.29 version (see the GitHub branch for NS3.26 version support)
   * Works on Linux. Can get it working on Windows, if the NS3 library port is available to Windows.
   * For high-fidelity WLAN PHY and Channel modeling, MATLAB WLAN Toolbox is recommended. Included example usage for 802.11a.
   * For proper visualization of the included examples, display should be of Full-HD (1920x1080) resolution.

## Example scenarios
Following example scenarios are included in this repository:
   1. WLAN Infrastructure Example
   2. Truck Platooning Example with V2X
   3. Manhattan Grid Hazard Warning Example with V2X

See the included documentation in 'doc' folder, for more details.

## Folders in the repository
   * doc - Documentation about the co-simulation and included examples
   * mlCode/mlWrappers - MATLAB wrappers over NS3
   * mlCode/mlWiFiPhyChannel - Sample MALTAB code using MATLAB WLAN Toolbox Phy and Channel modeling
   * native/mexBindings - Mex bindings over native C++ classes of NS3
   * native/mlPhy - Additional C++ classes for NS3 to invoke MATLAB WLAN Toolbox Phy and Channel models
   * scenarios - Contains example scenarios written in MATLAB that utilize the MATLAB-NS3 co-simulation
   * videos - Recorded videos, expaining the demo scenarios

## Setting up the co-simulation environment
Follow these steps to setup this co-simulation:
1. Download the source code (or download and extract the zip file). This gives out MATLAB-NS3 folder.
1. Download NS-3.29 from https://www.nsnam.org/release/ns-allinone-3.29.tar.bz2.
   *	Untar and place NS-3 source folder 'ns-allinone-3.29\' inside the MATLAB-NS3 folder
   *	Execute ‘NS3-build.sh’ to build all the necessary NS3 libraries using the following command
   
    `$sh NS3-build.sh`

   **Note:** *It is strongly recommended that you add LD_LIBRARY_PATH export to the shell startup script so that it is set automatically at startup.*

1. Add path to 'LD_LIBRARY_PATH' in the startup script
   * If you use bash shell, add this line at the end of ~/.bashrc file:

    `export LD_LIBRARY_PATH=<MATLAB-NS3 BASE FOLDER>/ns-allinone-3.29/ns-3.29/build/lib:$LD_LIBRARY_PATH`

   * If you use csh / tcsh, add the following line at the end of ~/.cshrc file:

    `setenv LD_LIBRARY_PATH<MATLAB-NS3 BASE FOLDER>/ns-allinone-3.29/ns-3.29/build/lib:$LD_LIBRARY_PATH`

   **Note:** *You have to launch new terminal (shell) or restart the PC to get the environment with updated LD_LIBRARY_PATH.*

1. Launch MATLAB from the new terminal. Go to the folder MATLAB-NS3.
1.	Run ‘buildMex.m’ to build Mex-binaries in the MATLAB Command Window.

    `>>MATLAB-NS3/native/mexBindings/buildMex`

   **Note:** *You may ignore warnings about GCC compiler version, thrown by MATLAB MEX. It works on Debian 8 (GCC version 4.9.x) and Debian 9 (GCC version 6.3.x). Should work with other GCC versions also.*

## Running the example scenarios
All examples are placed under ‘scenarios’ folder. Following steps are applicable to run any of the examples in this folder.
1.	Go to any example folder, such as: MATLAB-NS3/scenarios/truckPlatooning/
2.	Run ‘scenario.m’ script of any example. It might take around 2-3 minutes to complete. During this time the terminal will remain busy.

    **Note:** *Running the simulation scenario will clear all the variables, close all the figures and unload all the functions in the current workspace.*

    `>>scenario.m`

3.	To visualize the results of the simulation, run the MATLAB script in the ‘visualizer’ folder of the same example.

    `>>topologyVisualizer.m`


## Attack Model
Two data integrity attacks were incorporated into the simulation. These two include GPS Spoofing and Sensor Decption Attack.

1. GPS Spoofing: To integrate this attack in the simulation, uncomment line 105 (Simulator.Schedule('WSMPTraffic.runWSMPApp', 1, GPSArgs);) in hazard.m. Afterwards, run the simulation again.
2. Sensor Deception: To integrate this attack, uncomment line 354 to 373 in scenario.m under the section "Fake Hazard Integration". Next, uncomment line 111 to 130,  157 to 196 in visualizerTraces.m. Then, run the simulation again.


## Blockchain Integration
After the data integrity attacks were modeled and integrated into the simulation, the blockchain-based ITS was implemented in the system. The blockchain-based ITS consists of four parts namely, Consortium Blockchain, Block Structure, Smart Contracts, and Consensus Algorithm. All these components work hand in hand to fully implement the blockchain in the system.
1. Consortium Blockchain: used RSUs as our pre-selected nodes. The role of these nodes was to authenticate the data being broadcasted in the network. Since there are only four RSUs, it enables faster consensus and block generation.
2. Block Structure:  main component of the blockchain implementation.  The components of a block include the hash of the current block, Time Stamp, Main Data, Hash of the previous block, and other information. The Main Data contained the ID and location of a hazard while Other Information consisted of index and nonce. Hashes  used  the  SHA-256  cryptographic  hash  algorithm  which  provided  the  data  immutability feature of the system.
3. Smart Contracts: used to filter data that would go through the consensus algorithm. The smart contract (SmartContracts.m) can validate all the real hazards from the fake ones.
4. Consensus Algorithm: a  Practical  Byzantine  Fault  Tolerance  consensus  algorithm  was  used  because  of  the vehicular network's need for real timing. A whole module was created (ConsensusAlgorithm.m) to implement this whole process in the simulation. Different types of packet were used for each step of PBFT.
