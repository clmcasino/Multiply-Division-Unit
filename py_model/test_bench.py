#!/usr/bin/python3

#must be run inside py_model directory



divisorSampleFile="../common/divisorInSample.txt"
divisorHWResults="../common/divisorHWResults.txt"
divisorLogFile="../common/divisorLogFile.txt"
sampleFile="../common/inSample.txt"
logFile="../common/logFile.txt"
numSample=200000

import sys
lib="../py_lib"
sys.path.append(lib)
import os
import subprocess

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
if(flag=='n' or flag=='N'):
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
if(flag=='y' or flag=='Y'):
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

#Check divisor hardware
flag=input("Do yo want to check the divisor hardware?(y/N)\n")
if (flag=='y' or flag=='Y'):
    flag=input("Do yo want to create a new inmput stimuli file?(y/N)\n")
    if (flag=='y' or flag=='Y'):
        print("File with {} stimuli will be created as {}!".format(numSample,divisorSampleFile))
        #firstly we create two file, second are samples while first is just if samples
        #have to be interpreted signed or unsigned
        binStimFileGen("temp0",numSample,1,False,1,1,'')
        binStimFileGen("temp1",numSample,2,True,32,32,' ')
        lines=0
        #merge the two file
        with open("temp0","r") as pointer0, open("temp1","r") as pointer1, open(divisorSampleFile,"w") as fout_pointer:
            for line1, line2 in zip(pointer0,pointer1):
                nums=line2.split()
                if (int(nums[1],2)==0):
                    pass
                else:
                    fout_pointer.write(line1[0:len(line1)-1]+' '+line2)
                    lines+=1
        print("File with {} stimuli has been created as {}!".format(lines,divisorSampleFile))
        os.remove("temp0")
        os.remove("temp1")
    subprocess.call(["vsim", "-c", "-do", "../common/sim/divisorNOGUI.do"])
    with open(divisorSampleFile,"r") as fin_pointer, open(divisorHWResults,"r") as hwres_pointer, open(divisorLogFile,"w") as log_pointer:
        i=1
        error_count=0
        for line_in, line_hwres in zip(fin_pointer,hwres_pointer):
            str_in=line_in.split()
            str_hwres=line_hwres.split()
            if (str_in[0]=='0'):          #signed case
                a=twos_comp(int(str_in[1],2),len(str_in[1]))
                b=twos_comp(int(str_in[2],2),len(str_in[2]))
                qS=quotient_software(a,b)
                sS=reminder_software(a,b)
                qH=twos_comp(int(str_hwres[0],2),len(str_hwres[0]))
                sH=twos_comp(int(str_hwres[1],2),len(str_hwres[1]))
            else:                       #unsigned case
                a=int(str_in[1],2)
                b=int(str_in[2],2)
                qS=quotient_software(a,b)
                sS=reminder_software(a,b)
                qH=int(str_hwres[0],2)
                sH=int(str_hwres[1],2)
            error=errorCheck(qS,qH) or errorCheck(sS,sH)
            if (error):
                error_count+=1
                log_pointer.write("MISTAKE #{}\tINSTRUCTION {}\n".format(i,str_in[0]))
                log_pointer.write("Sample  :\t {} \t {}\n".format(a,b))
                log_pointer.write("Expected:\t {} \t {}\n".format(qS,sS))
                log_pointer.write("Had:     \t {} \t {}\n".format(qH,sH))
                log_pointer.write("\n")
            i+=1
        if(error_count==0):
            print("Yeeeee! The divisor seems working!")
        else:
            print("Ops! There are {} mistakes, please check the log file".format(error_count))
