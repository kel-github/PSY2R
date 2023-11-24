# Details of where we are up to (to date)
A portion of the base Pascal source code has been implemented in Python, see next section for files.

## key files and functions
GCR.py - got correct p-value (as validated by Psy) by calling Gcr_ProbExact function. Gcr_crit still not returning expected value - assuming an error with PillaiApproxOriginals (*START HERE WHEN RESUMING WORK)

## Overall progress
The majority of the code that is required to calculate and output the confidence intervals (as shown in the main output of PSY) has been finished.

## To run GCR
First: Install scipy then activate the virtual environment
`python GCR.py`
This is using hardcoded values at the bottom of the file.

