@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.3\\bin
call %xv_path%/xsim camera_tb_behav -key {Behavioral:sim_1:Functional:camera_tb} -tclbatch camera_tb.tcl -view C:/Users/Edgar/dmpro16/src/fpga/rpi_camera/camera_tb_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
