TOPDIR := ..
WORKDIR := ${TOPDIR}/vivado-workdir
SCRIPTDIR := ${TOPDIR}/scripts
BNNDIR := ${TOPDIR}/bnn
VERILOGDIR := ${BNNDIR}/verilog
FPGACONSTRDIR := ${TOPDIR}/fpga-constrs
VIVADO := vivado -tempDir ${WORKDIR}


synth:
	sbt run
	@echo "Starting synthesis"
	@echo "========================"
	@env TOPDIR=${CURDIR} \
	  DCP=${SYNTH_DCP} \
	  UTIL_RPT=${SYNTH_UTIL_RPT} \
	  TIMING_RPT=${SYNTH_TIMING_RPT} \
	  TIMING_SUMMARY=${SYNTH_TIMING_SUMMARY} \
    DRC_RPT=${SYNTH_DRC_RPT} \
	  TOP=${SYNTH_TOP} \
		${VIVADO} -mode batch -source ${SCRIPTDIR}/synth.tcl |\
      tee ${SYNTH_LOG}
