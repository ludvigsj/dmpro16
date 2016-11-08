@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.3\\bin
call %xv_path%/xelab  -wto efa6c0298d674da0895771d923a8dd87 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot camera_tb_behav xil_defaultlib.camera_tb -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
