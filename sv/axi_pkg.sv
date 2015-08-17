`ifndef AXI_PKG_SVH
`define AXI_PKG_SVH

package axi_pkg;
	//scheduler and packages
	typedef class axi_master_write_scheduler;
	typedef class axi_master_write_scheduler_packages;

	//driveres
	typedef class axi_master_write_response_driver;
	typedef class axi_master_write_data_driver;
	typedef class axi_master_write_address_driver;
	typedef class axi_master_write_main_driver;
	typedef class axi_master_write_base_driver;

	//confing and frames
	typedef class axi_master_config;
	typedef class axi_slave_config;
	typedef class axi_config;
	typedef class axi_frame;
	typedef class slave_config_factory;

	// axi_mssg
	typedef class axi_slave_response;
	typedef class axi_waiting_resp;
	typedef class unique_id_struct;
	typedef class axi_mssg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	`include "sv/axi_types.sv"

	`include "sv/axi_frame.sv"
	`include "sv/axi_config.sv"

	//utils
	`include "sv/utils/axi_master_write_base_driver.sv"
	`include "sv/utils/axi_master_write_main_driver.sv"
	`include "sv/utils/axi_master_write_data_driver.sv"
	`include "sv/utils/axi_master_write_address_driver.sv"
	`include "sv/utils/axi_master_write_response_driver.sv"
	`include "sv/utils/axi_mssg.sv"
	`include "sv/utils/axi_master_write_scheduler_packages.sv"
	`include "sv/utils/axi_master_write_scheduler.sv"

	//add include for master
	`include "sv/master/axi_master_config.sv"
	`include "sv/master/axi_master_write_driver.sv"
//	`include "sv/master/axi_master_write_monitor.sv"
	`include "sv/master/axi_master_write_sequencer.sv"
	`include "sv/master/axi_master_write_sequence_lib.sv"

//	`include "sv/master/axi_master_read_driver.sv"
//	`include "sv/master/axi_master_read_monitor.sv"
//	`include "sv/master/axi_master_read_sequencer.sv"
//	`include "sv/master/axi_master_read_sequence_lib.sv"

	//add include for slave
	`include "sv/slave/axi_slave_config.sv"

//	`include "sv/slave/axi_slave_write_driver.sv"
//	`include "sv/slave/axi_slave_write_monitor.sv"
//	`include "sv/slave/axi_slave_write_sequencer.sv"
//	`include "sv/slave/axi_slave_write_sequence_lib.sv"

	`include "sv/slave/axi_slave_read_driver.sv"
	`include "sv/slave/axi_slave_read_sequencer.sv"
	`include "sv/slave/axi_slave_read_sequence_lib.sv"


endpackage : axi_pkg


`endif