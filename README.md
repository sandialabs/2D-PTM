# 2D-PTM
This code is for the analysis of atomic-resolution images through the two-dimensional polyhedral template matching method (2D-PTM). It is primarily designed to identify lattice structures in these images based on pre-defined templates, although it is also capable of pulling out other information as well, such as the relative crystal orientations or the centrosymmetry parameter.  A full description of the underlying methods with various applications is provided in [1] 

[1] D. Britton, A. Hinojos, M. Hummel, D.P. Adams, D.L. Medlin, "Application of the polyhedral template matching method for characterization of 2D atomic resolution electron microscopy images".
Materials Characterization 213 (2024) 114017.  https://doi.org/10.1016/j.matchar.2024.114017



Installation:

Required toolboxes and functions: 

![image](https://github.com/user-attachments/assets/a13909f8-6a6e-467e-8a0a-ccc221fbe3e4)

In addition to the code included in the distribution, the user will also need to install the following MATLAB toolboxes:   Signal Processing, Image Processing, Statistics and Machine Learning, and Parallel Computing.   

Additionally, although it is not strictly necessary for the analysis part of the code to run, in order to take advantage of some of the graphical output options, users should also install the export_fig.m toolbox, which is available at the following MATLAB file exchange link: 

https://www.mathworks.com/matlabcentral/fileexchange/23629-export_fig 

In addition to our original code, we also include in our distribution the following two functions, which are necessary for the code to run: FastPeakFind.m [2] and Kabsch.m [3]. 


Getting started 

The example_call.m script provides detailed examples of how to run the code. You can also consult the ExampleData folder for an example input file and the resulting outputs. 


How the code works 

The flow-chart in Figure 1 provides an overview of the user inputs, analysis, and the connections between the different functions. 

In step 1, the user selects an atomic resolution image to analyze, ideally a tif or png file. 

After choosing a file and defining a file name, step 2 of the process is to identify the atomic peak positions. This is done using the DispImage.m function. The DispImage.m function is run by the user and requires the chosen file name as the input. It produces an array of peak positions as the output. 

The DispImage.m function automatically calls the atom_detect.m function no user interaction is needed.  The atom_detect.m function additionally calls the optimize_tmplt_size.m, the center_template.m, and the FastPeakFind.m [2] functions.  This set of functions measures the x and y positions of each of the atomic peaks identified in the image and returns them as an Nx2 array, where N is the number of peaks identified. Additionally, the DispImage.m function plots the peaks overlayed on top of the original image. One example of this graphical output is shown in Figure 2. 

Once the array of peak positions is created, step 3 analyzes the peak positions to determine information about the image. This step is done using the identifyAll_parfor.m function, which is run by the user and takes at least the array output from the DispImage.m function as an input. The breakdown of the identifyAll_parfor.m function is as follows: 

		Read in the peak position array and initialize the structure array output. 

		Define templates for FCC, BCC, and HCP lattice structures. 

		Find the Delaunay triangulation of the points. 

		Use the NN_finder_DT.m function to identify nearest neighbors of each atom peak. 

		Use the findAll.m function to determine the following information at each atomic peak: 

		Local lattice structure. 

		Relative orientation. 

		Makes use of the QrotationKabsch.m and Kabsch.m [3] functions.  

		The least root-mean-squared deviation value for the template fit. 

		Makes use of the RMSD.m function. 

		The centrosymmetry parameter. 

Additional values, such as scaling factor (for the template match), nearest neighbor lists, and the Delaunay triangulation information, are also saved. No user interaction is required for any of the functions called within the identifyAll_parfor.m function. 

Finally, once the analysis is complete, step 4 of the process employs the plotValues.m function to display the results. The plotValues.m function is called by the user and takes at least the structure array output from the identifyAll_parfor.m function and a keyword indicating the desired plot as inputs. There are a variety of different options that can be used to adjust the output; see an extensive list in the example_call.m script. An example of the plots from the data outputs provided from the from the 2DPTM code can be seen in Figure 3.  

The export_fig.m function, which is used in the plotValues.m function if the proper input is given, can be used to automatically save any display output. As noted above, in the installation description, export_fig.m is not distributed with our code, but it can be downloaded separately from the MATLAB Central File Exchange.  If export_fig.m is not installed, this will limit the ability to save the image with a few special features; otherwise, the visualization will function without the use of export_fig.m. Examples of the different output plots can be found in the ExampleData folder. 



![image](https://github.com/user-attachments/assets/5c6bf6a1-c9bd-4377-8653-0f110142780a)


![image](https://github.com/user-attachments/assets/0c69943f-9fd9-4438-a2b0-96e69fdc167d)



![image](https://github.com/user-attachments/assets/13e9ca2d-3b8d-4310-9ff2-e38a8bfd196d)





References:   

[1]  D. Britton, A. Hinojos, M. Hummel, D.P. Adams, D.L. Medlin, "Application of the polyhedral template matching method for characterization of 2D atomic resolution electron microscopy images".
Materials Characterization 213 (2024) 114017.  https://doi.org/10.1016/j.matchar.2024.114017

[2] A. Natan "Fast 2D peak finder." MATLAB Central File Exchange. Available at https://www.mathworks.com/matlabcentral/fileexchange/37388-fast-2d-peak-finder (2021) 

[3] E. Schreiber. Kabsch algorithm, MATLAB Central File Exchange.  Available at https://www.mathworks.com/matlabcentral/fileexchange/25746-kabsch-algorithm (2023)
 
 
