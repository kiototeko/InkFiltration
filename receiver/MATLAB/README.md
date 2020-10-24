# MATLAB code

* **test.m** is the file used to test all modulation schemes. 
* **genericPattern.m** is the function used to load and process each audio file. 
	* This function may be invoked the following way: genericPattern(Filename, {"Blank" or "Text"})
	* *Blank* is used for DPPM recordings and *Text* for FPM-DPPM.
	* The function returns the inverse of the Bit Error Ratio. To compute the Bit Error Ratio, subtract the result to 1.
* All samples used for the paper can be downloaded [here](https://drive.google.com/file/d/1i4jgTm4fGE4vT6IUTMaa1_sHq3aUKbgj/view?usp=sharing). These samples should be put into **samples2/** directory.
* If a new recording is made keep in mind that the name of this audio file does matter. Indeed, it should be of the type C[number]..., where *number* indicates the type of printer {1:HP,2:Epson,3:Canon}.
