#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2019.1.1 (64-bit)
#
# Filename    : compile.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for compiling the simulation design source files
#
# Generated by Vivado on Sat Aug 10 15:53:26 CEST 2019
# SW Build 2580384 on Sat Jun 29 08:04:45 MDT 2019
#
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
#
# usage: compile.sh
#
# ****************************************************************************
set -Eeuo pipefail
echo "xvlog --incr --relax -prj tb_divisorUnit_vlog.prj"
xvlog --incr --relax -prj tb_divisorUnit_vlog.prj 2>&1 | tee compile.log

