#!/usr/bin/python3

lib="../py_lib"
import sys
sys.path.append(lib)

from bin_lib import *

# divide_software(dividend,divisor):
#
# DESCRIPTION
#    Computes integer quotient.
# INPUT
#    Needs as inputs:
#       dividend    : as signed integer value.
#       divisor     : as signed integer value.
# OUTPUT
#    Returns the quotient expressed as signed integer value.

def quotient_software(dividend,divisor):
    if (divisor==0):
        return "div0"
    return  int(float(dividend)/divisor)

# reminder_software(dividend,divisor):
#
# DESCRIPTION
#    Computes integer reminder.
# INPUT
#    Needs as inputs:
#       dividend    : as signed integer value.
#       divisor     : as signed integer value.
# OUTPUT
#    Returns the reminder expressed as signed integer value.

def reminder_software(dividend,divisor):
    if (divisor==0):
        return "div0"
    reminder=abs(dividend)%abs(divisor)
    if (dividend<0):
        reminder=-reminder
    return reminder

# SRT_unsignedDivisor(dividend,divisor,inPar):
#
# DESCRIPTION
#    Model for the hardware algorithm of division.
# INPUT
#    Needs as inputs:
#       dividend    : as unsigned integer value.
#       divisor     : as unsigned integer value.
#       inPar       : as unsigned integer value referred to dividend.
# OUTPUT
#    Returns the reminder expressed as signed integer value.

def SRT_unsignedDivisor(dividend,divisor,inPar):

    #div by zero
    if (divisor==0):
        return "div0"

    z=dividend/2**(inPar+1)
    d=divisor/2**(inPar+1)

    #out of range condition
    if (z>=0.5 or z<-0.5):
        s=z
        correction_flag=True
    else:
        s=z*2
        correction_flag=False

    loop_iteration=0
    while ((d<0.5 and d>0)):
        loop_iteration+=1
        d=d*2

    if loop_iteration==0:
        loop_iteration=1
    #standard iterations
    q=""
    for i in range(0,loop_iteration):
        if(s>=0.5):
            _q=1
            s=s-d
        else:
            if (s>=-0.5):
                _q=0
                s=s
            else :
                _q=2
                s=s+d
        s=s*2
        q=q+str(_q)
    s=s/2

    #quotient conversion
    quotient=0
    for i in range(0,loop_iteration):
        if (q[len(q)-1-i]=="1"):
            quotient=quotient+2**i
        else :
            if (q[len(q)-1-i]=="2"):
                quotient=quotient-2**i
            else:
                quotient=quotient
    #correction of result
    if(((s>0) and (z<0)) or ((s<0) and (z>0))):
        if(((s>0) and (d<0)) or ((s<0) and (d>0))):
            s=s+d
            quotient=quotient-1
        else:
            s=s-d
            quotient=quotient+1

    #final correction
    if (correction_flag):
        s=s*2
        quotient=quotient*2

    s=s*(2**(inPar+1-loop_iteration))
    res=[]
    res+=[quotient]
    res+=[s]
    return res

# SRT_signedDivisor(dividend,divisor,inPar):
#
# DESCRIPTION
#    Model for the hardware algorithm of division.
# INPUT
#    Needs as inputs:
#       dividend    : as signed integer value.
#       divisor     : as signed integer value.
#       inPar       : as unsigned integer value referred to dividend.
# OUTPUT
#    Returns the reminder expressed as signed integer value.

def SRT_signedDivisor(dividend,divisor,inPar):

    #div by zero
    if (divisor==0):
        return "div0"

    #overflow condition
    if (dividend==-1<<(inPar-1) and divisor==-1 ):
        return "ovf"

    z=dividend/2**(inPar)
    d=divisor/2**(inPar)

    #out of range condition
    if (z>=0.5 or z<-0.5):
        s=z
        correction_flag=True
    else:
        s=z*2
        correction_flag=False

    loop_iteration=0
    while ((d<0.5 and d>0) or (d>=-0.5 and d<0)):
        loop_iteration+=1
        d=d*2

    if loop_iteration==0:
        loop_iteration=1
    #standard iterations
    q=""
    if(d>0):
        for i in range(0,loop_iteration):
            if(s>=0.5):
                _q=1
                s=s-d
            else:
                if (s>=-0.5):
                    _q=0
                    s=s
                else :
                    _q=2
                    s=s+d
            s=s*2
            q=q+str(_q)
    else:
        for i in range(0,loop_iteration):
            if(s>=0.5):
                _q=1
                s=s+d
            else:
                if (s>=-0.5):
                    _q=0
                    s=s
                else :
                    _q=2
                    s=s-d
            s=s*2
            q=q+str(_q)
    s=s/2
    #quotient conversion
    quotient=0
    for i in range(0,loop_iteration):
        if (q[len(q)-1-i]=="1"):
            quotient=quotient+2**i
        else :
            if (q[len(q)-1-i]=="2"):
                quotient=quotient-2**i
            else:
                quotient=quotient
                
    #correction of result
    if(d>0):
        if(((s>0) and (z<0)) or ((s<0) and (z>0))):
            if(((s>0) and (d<0)) or ((s<0) and (d>0))):
                s=s+d
                quotient=quotient-1
            else:
                s=s-d
                quotient=quotient+1
    else:
        if(((s>0) and (z<0)) or ((s<0) and (z>0))):
            if(((s>0) and (d<0)) or ((s<0) and (d>0))):
                s=s+d
                quotient=quotient+1
            else:
                s=s-d
                quotient=quotient-1

    #sign of q correction
    if (divisor<0):
        quotient=-quotient

    #final correction
    if (correction_flag):
        s=s*2
        quotient=quotient*2

    s=s*(2**(inPar-loop_iteration))
    res=[]
    res+=[quotient]
    res+=[s]
    return res
