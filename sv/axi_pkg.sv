`ifndef AXI_PKG
`define AXI_PKG

package axi_pkg;
	// uvm lib
	import uvm_pkg::*;
	// TODO dodat typedef class .. .
	`include "uvm_macros.svh"

	`include "sv/axi_config.sv"
	`include "sv/axi_env.sv"
	`include "sv/axi_if.sv"
	`include "sv/axi_frame.sv"
	`include "sv/axi_types.sv"

	//utils
	`include "sv/utils/axi_master_write_base_driver.sv"
	`include "sv/utils/axi_master_write_data_driver.sv"
	`include "sv/utils/axi_master_write_address_driver.sv"
	`include "sv/utils/axi_master_write_main_driver.sv"
	`include "sv/utils/axi_master_write_response_driver.sv"

	//add include for master
	`include "sv/master/axi_master_config.sv"

	`include "sv/master/axi_master_write_driver.sv"
	`include "sv/master/axi_master_write_monitor.sv"
	`include "sv/master/axi_master_write_sequencer.sv"
	`include "sv/master/axi_master_write_sequence_lib.sv"

	`include "sv/master/axi_master_read_driver.sv"
	`include "sv/master/axi_master_read_monitor.sv"
	`include "sv/master/axi_master_read_sequencer.sv"
	`include "sv/master/axi_master_read_sequence_lib.sv"

	//add include for slave
	`include "sv/slave/axi_slave_config.sv"

	`include "sv/slave/axi_slave_write_driver.sv"
	`include "sv/slave/axi_slave_write_monitor.sv"
	`include "sv/slave/axi_slave_write_sequencer.sv"
	`include "sv/slave/axi_slave_write_sequence_lib.sv"

	`include "sv/slave/axi_slave_read_driver.sv"
	`include "sv/slave/axi_slave_read_monitor.sv"
	`include "sv/slave/axi_slave_read_sequencer.sv"
	`include "sv/slave/axi_slave_read_sequence_lib.sv"

	`include "sv/utils/axi_master_write_scheduler_packages.sv"
	`include "sv/utils/axi_master_write_scheduler.sv"
	`include "sv/utils/axi_mssg.sv"

endpackage : axi_pkg


`endif