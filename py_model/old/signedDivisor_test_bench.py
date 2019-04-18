#!/usr/bin/python3

lib="../py_lib"
sampleFile="../common/inSample.txt"
logFile="../common/logFile.txt"
numSample=200000

import sys
sys.path.append(lib)

from div_models import *
from in_gen import binStimGen
from bin_lib import *

binStimGen(sampleFile,numSample,2,True,32,32,' ')
with open(sampleFile,"r") as fin_pointer, open(logFile,"w") as log_pointer:
    i=0
    for line in fin_pointer:
        str_num=line.split()
        #32 bits
        z=twos_comp(int(str_num[0],2),len(str_num[0]))
        d=twos_comp(int(str_num[1],2),len(str_num[1]))
        qS=quotient_software(z,d)
        sS=reminder_software(z,d)
        SRT=SRT_signedDivisor(z,d,32)
        if SRT!="div0":
            if ((qS != SRT[0]) or (sS != SRT[1])):
                i+=1
                log_pointer.write("MISTAKE #{}\n".format(i))
                log_pointer.write("Sample  :\t {} \t {}\n".format(z,d))
                log_pointer.write("Expected:\t {} \t {}\n".format(qS,sS))
                log_pointer.write("Had:     \t {} \t {}\n".format(SRT[0],SRT[1]))
                log_pointer.write("\n")
    print(i)
