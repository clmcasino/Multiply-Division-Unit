#!/usr/bin/python3

lib="../py_lib"
sampleFile="../common/inSample.txt"
logFile="../common/logFile.txt"
numSample=1000

import sys
sys.path.append(lib)
import os

from div_models import *
from mult_models import *
from in_gen import binStimFileGen
from bin_lib import *

#This testbench should:
#   1) Create random 32 bit M extension instructions
#   2) Check the model
#   3) Check the harware

#Generation of stimuli as <funct3> <op0> <op1>
flag=input("Do yo want to create a new inmput stimuli file?(Y/n)\n")
if(flag=='n'):
    pass
else:
    print("File with {} stimuli will be created as {}!".format(numSample,sampleFile))
    binStimFileGen("temp0",numSample,1,False,3,3,'')
    binStimFileGen("temp1",numSample,2,True,32,32,' ')
    with open("temp0","r") as pointer0, open("temp1","r") as pointer1, open(sampleFile,"w") as fout_pointer:
        for line1, line2 in zip(pointer0,pointer1):
            fout_pointer.write(line1[0:len(line1)-1]+' '+line2+'\n')
    os.remove("temp0")
    os.remove("temp1")

#Check the models
flag=input("Do yo want to check the models?(y/N)\n")
if(flag=='y'):
    print("Models will be checked!")
    with open(sampleFile,"r") as fin_pointer, open(logFile,"w") as log_pointer:
        i=0
        for line in fin_pointer:
            str_num=line.split()
            if   (str_num[0]=="000"):
                a=twos_comp(int(str_num[1],2),len(str_num[1]))
                b=twos_comp(int(str_num[2],2),len(str_num[2]))
                c=BE_multiplier(a,b,True,32)
                cS=software_mult(a,b)
                if(c!=cS):
                    error=True
            elif (str_num[0]=="001"):
                a=twos_comp(int(str_num[1],2),len(str_num[1]))
                b=twos_comp(int(str_num[2],2),len(str_num[2]))
                c=BE_multiplier(a,b,True,32)
                cS=software_mult(a,b)
                if(c!=cS):
                    error=True
            elif (str_num[0]=="010"):
                a=twos_comp(int(str_num[1],2),len(str_num[1]))
                b=int(str_num[2],2)
                c=BE_multiplier(a,b,False,32)
                cS=software_mult(a,b)
                if(c!=cS):
                    error=True
            elif (str_num[0]=="011"):

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
    if (i=0):
        print("Yeeeee, at least we understood something!")
