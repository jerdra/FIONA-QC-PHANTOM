#!/usr/bin/env python 

"""
Visualizes output of multi-site ABCD pipeline for quantifying scanner stability metrics 

Usage: 
    ABCD_qc_vis.py <qc_output> 

Arguments: 
    <qc_output>                     Output of ABCD phantom QC pipeline 

""" 



import matplotlib.pyplot 
import seaborn as sns
import os 
import numpy as np 
from docopt import docopt




def main(): 

    arguments = doctopt(__doc__) 

    qc_dir  =           arguments['<qc_output>'] 






if __name__ = '__main__': 
    main() 



