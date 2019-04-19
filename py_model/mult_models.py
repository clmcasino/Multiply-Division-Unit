lib="../py_lib"
import sys
sys.path.append(lib)

from bin_lib import *

# software_mult2s(op0,op1,outpar):
#
# DESCRIPTION
#    Computes regular signed muliplication starting from 2's complement strings.
# INPUT
#    Needs as inputs:
#       multiplicand    as 2's complement number expressed as strings.
#       multiplier      as 2's complement number expressed as strings.
#       output          parallelism as an integer.
# OUTPUT
#    Returns the 2's complement result expressed as a string.

def software_mult2s(op0,op1,outpar):
    multiplicand=int(op0,2)
    multiplicand=twos_comp(multiplicand,len(op0))
    multiplier=int(op1,2)
    multiplier=twos_comp(multiplier,len(op1))
    product=multiplicand*multiplier
    return printer_2s(product,outpar)+'\n'

# software_mult(op0,op1):
#
# DESCRIPTION
#    Computes regular signed muliplication starting from integers.
# INPUT
#    Needs as inputs:
#       multiplicand    as integer.
#       multiplier      as integer.
# OUTPUT
#    Returns the result expressed as integer.

def software_mult(op0,op1):
    return op0*op1

################FUNCTION FOR SIGNED MBE RADIX2 MULTIPLICAND####################

# recode_calculator(multiplier,i):
#
# DESCRIPTION
#    Computes recode bits according to the MBE method.
# INPUT
#    Needs as inputs:
#       multiplier as 2's complement number expressed as strings.
#       iterator (integer) expliciting to which partial products recode bits are referred to.
# OUTPUT
#    Returns the recoding bits expressed as a string.

def recode_calculator(multiplier,i):
    if i==0:
        return (multiplier[len(multiplier)-2:len(multiplier)]+'0')
    else:
        return (multiplier[len(multiplier)-(2*i+2):len(multiplier)-(2*i-1)])

# pp_calculator(multiplicand, recode):
#
# DESCRIPTION
#    Computes recoded multplicand according to the MBE method.
#    NOTE!!! In case of negative multiplicand output is just inverted!
#    a=2 ----> ~a=-3    010 ----> 101
# INPUT
#    Needs as inputs:
#       multiplicand    :as integer number.
#       recode          :as 3 bit string expressing x(n+1) x(n) x(n-1).
# OUTPUT
#    Returns the recoded multiplicand.

def pp_calculator(multiplicand, recode):
    if   recode=='000' or recode=='111':
        return(0)
    elif recode=='001' or recode=='010':
        return(multiplicand)
    elif recode=='101' or recode=='110':
        return(~multiplicand)
    elif recode=='011':
        return(multiplicand<<1)
    else:
        return(~(multiplicand<<1))

def inv_evaluator(recode):
    if recode=='101' or recode=='110' or recode=='100':
        return(1)
    else:
        return(0)

# MBEr4_signedMultiplier_wtTrunc (multiplier,multiplicand)
# DESCRIPTION
#    Computes regular muliplication.
# INPUT
#    Needs as inputs:
#       multiplicand
#       multiplier as 2's complement number expressed as strings
#       output parallelism as an integer
#       number of LSBs to be truncated
# OUTPUT
#    Returns the 2's complement result expressed as a string.

def MBEr4_signedMultiplier_wtTrunc (op0,op1,outpar,lsbs):
    if len(op0)!=len(op1):
        DADDALEVELS=int(input("How many DADDALEVELS should I set?\n"))
    else:
        DADDALEVELS=len(op0)/2 + 1
    multiplicand=int(op0,2)
    multiplicand=twos_comp(multiplicand,len(op0))
    multiplier=int(op1,2)
    multiplier=twos_comp(multiplier,len(op1))

    # Initialize pp matrix
    pp=[]
    i=0
    inv=0

    # Calculating partial products
    while i < DADDALEVELS-1:
        recode_ctr=recode_calculator(op1,i)
        pp.append((pp_calculator(multiplicand,recode_ctr)<<(2*i))+inv)
        inv=inv_evaluator(recode_ctr)<<(2*i)
        i+=1
    pp.append(inv)

    # Truncating LSBs if requested

    ending_str='0'*lsbs
    i=0
    while i<DADDALEVELS:
        original_str=printer_2s(pp[i],outpar)
        new_str=original_str[0:len(original_str)-lsbs]+ending_str
        new_num=int(new_str,2)
        pp[i]=twos_comp(new_num,len(new_str))
        i+=1
    # Summing pp
    i=0
    product=0
    while i<DADDALEVELS:
        product=pp[i]+product
        i+=1

    # Writing result
    return printer_2s(product,outpar)+'\n'


# MBEr4_signedMultiplier_wtTrunc (multiplier,multiplicand)
# DESCRIPTION
#    Computes regular muliplication.
# INPUT
#    Needs as inputs:
#       multiplicand
#       multiplier as 2's complement number expressed as strings
#       output parallelism as an integer
#       number of LSBs to be truncated
# OUTPUT
#    Returns the 2's complement result expressed as a string.

def BE_multiplier (multiplicand,multiplier,signed_unsigned_n,parallelism):
    if (~signed_unsigned_n):
        #we need to insert a guard bit!
        parallelism+=1
    mult_string=printer_2s(multiplier,parallelism)

    a=multiplicand*(2**(parallelism-1))
    if (int(mult_string[parallelism-1])):
        p=-a
    else:
        p=0
    p=p/2
    for i in range(0,parallelism-1):
        if mult_string[parallelism-i-2]=='0' and mult_string[parallelism-i-1]=='0':
            p=p
        elif mult_string[parallelism-i-2]=='0' and mult_string[parallelism-i-1]=='1':
            p=p+a
        elif mult_string[parallelism-i-2]=='1' and mult_string[parallelism-i-1]=='0':
            p=p-a
        else:
            p=p
        p=p/2
    p=p*2
    return p
