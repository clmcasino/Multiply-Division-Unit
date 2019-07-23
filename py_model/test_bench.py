#!/usr/bin/python3

lib="../py_lib"
sampleFile="../common/inSample.txt"
logFile="../common/logFile.txt"
numSample=200000

import sys
sys.path.append(lib)
import os

from div_models_v2 import *
from mult_models import *
from in_gen import binStimFileGen
from bin_lib import *

def errorCheck(a,b):
    d=abs(a-b)
    if (a!=0):
        e=100*d/a
    else:
        if (b!=0):
            return True
        else:
            return False
    if(e>0.1):
        return True
    else:
        return False

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
            fout_pointer.write(line1[0:len(line1)-1]+' '+line2)
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
            if   (str_num[0]=="000"): #000--->MUL
                a=twos_comp(int(str_num[1],2),len(str_num[1]))
                b=twos_comp(int(str_num[2],2),len(str_num[2]))
                c=BE_multiplier(a,b,True,32)
                cS=software_mult(a,b)
                error=errorCheck(cS,c)
            elif (str_num[0]=="001"): #001--->MULH
                a=twos_comp(int(str_num[1],2),len(str_num[1]))
                b=twos_comp(int(str_num[2],2),len(str_num[2]))
                c=BE_multiplier(a,b,True,32)
                cS=software_mult(a,b)
                error=errorCheck(cS,c)
            elif (str_num[0]=="010"): #010--->MULHSU
                a=twos_comp(int(str_num[1],2),len(str_num[1]))
                b=int(str_num[2],2)
                c=BE_multiplier(a,b,False,32)
                cS=software_mult(a,b)
                error=errorCheck(cS,c)
            elif (str_num[0]=="011"): #011--->MULHU
                a=int(str_num[1],2)
                b=int(str_num[2],2)
                c=BE_multiplier(a,b,False,32)
                cS=software_mult(a,b)
                error=errorCheck(cS,c)
            elif (str_num[0]=="100"): #100--->DIV
                a=twos_comp(int(str_num[1],2),len(str_num[1]))
                b=twos_comp(int(str_num[2],2),len(str_num[2]))
                qS=quotient_software(a,b)
                sS=reminder_software(a,b)
                #SRT=SRT_signedDivisor(a,b,32)
                SRT=SRTr2_divisor(a,b,32,1,-0.5,0)
                if SRT!="div0":
                    error=errorCheck(qS,SRT[0]) or errorCheck(sS,SRT[1])
            elif (str_num[0]=="101"): #101--->DIVU
                a=int(str_num[1],2)
                b=int(str_num[2],2)
                qS=quotient_software(a,b)
                sS=reminder_software(a,b)
                #SRT=SRT_unsignedDivisor(a,b,32)
                SRT=SRTr2_divisor(a,b,32,0,-0.5,0)
                if SRT!="div0":
                    error=errorCheck(qS,SRT[0]) or errorCheck(sS,SRT[1])
            elif (str_num[0]=="110"): #110--->REM
                a=twos_comp(int(str_num[1],2),len(str_num[1]))
                b=twos_comp(int(str_num[2],2),len(str_num[2]))
                qS=quotient_software(a,b)
                sS=reminder_software(a,b)
                SRT=SRTr2_divisor(a,b,32,1,-0.5,0)
                if SRT!="div0":
                    error=errorCheck(qS,SRT[0]) or errorCheck(sS,SRT[1])
            elif (str_num[0]=="111"): #111--->REMU
                a=int(str_num[1],2)
                b=int(str_num[2],2)
                qS=quotient_software(a,b)
                sS=reminder_software(a,b)
                SRT=SRTr2_divisor(a,b,32,0,-0.5,0)
                if SRT!="div0":
                    error=errorCheck(qS,SRT[0]) or errorCheck(sS,SRT[1])
            if (error):
                i+=1
                if (int(str_num[0],2)>3):
                    log_pointer.write("MISTAKE #{}\tINSTRUCTION {}\n".format(i,str_num[0]))
                    log_pointer.write("Sample  :\t {} \t {}\n".format(a,b))
                    log_pointer.write("Expected:\t {} \t {}\n".format(qS,sS))
                    log_pointer.write("Had:     \t {} \t {}\n".format(SRT[0],SRT[1]))
                    log_pointer.write("\n")
                else:
                    log_pointer.write("MISTAKE #{}\tINSTRUCTION {}\n".format(i,str_num[0]))
                    log_pointer.write("Sample  :\t {} \t {}\n".format(a,b))
                    log_pointer.write("Expected:\t {} \n".format(cS))
                    log_pointer.write("Had:     \t {} \n".format(c))
                    log_pointer.write("\n")
    if(i==0):
        print("Yeeeee, at least we understood something!")
    else:
        print("Ops, we have {} mistakes".format(i))
