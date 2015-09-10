#!/bin/sh

DEMO_HOME=/home/ELEA/aerdeljan/work/axi/all
TB_HOME=/home/ELEA/aerdeljan/work/axi/all
export TB_HOME

usage() {
    echo "Usage:  demo.sh [-batch]"
    echo ""
    echo "                ... all other Incisive Simulator/UVM options such as:"
    echo "                [+UVM_VERBOSITY=UVM_NONE | UVM_LOW | UVM_MEDIUM | UVM_HIGH | UVM_FULL]"
    echo "                [+UVM_SEVERITY=INFO | WARNING | ERROR | FATAL]"
    echo "                [-SVSEED  random | <integer-value>]"
    echo ""
    echo "        demo.sh -h[elp]"
    echo ""
}

# =============================================================================
# Get args
# =============================================================================
gui="-access rc -gui +tcl+$TB_HOME/sim_command.tcl"
other_args="";

while [ $# -gt 0 ]; do
   case $1 in
      -h|-help)
                        usage
                        exit 1
                        ;;
      -batch)
                        gui=""
                        ;;
      *)
                        other_args="$other_args $1"
                        ;;
    esac
    shift
done

# =============================================================================
# Execute
# =============================================================================

irun  $other_args \
  -uvmhome default \
  -incdir $DEMO_HOME/sv \
  -coverage b:u \
  -covoverwrite \
  -nowarn PMBDVX \
  +UVM_VERBOSITY=UVM_HIGH \
  +UVM_TESTNAME=axi_read_all_valid_frames \
  +svseed=RANDOM \
  $TB_HOME/axi_top.sv \
  $gui
 