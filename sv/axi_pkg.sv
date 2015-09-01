`ifndef AXI_PKG_SVH
`define AXI_PKG_SVH

`define tome_test
`define testing_includes
//`define andrea
//`define andrea_test

package axi_pkg;
	`ifdef tome_test


	`ifdef testing_includes
	typedef class axi_write_test_config;
	typedef class axi_master_write_env;

	`endif
	//scheduler and packages
	typedef class axi_master_write_scheduler;
	typedef class axi_master_write_scheduler_packages;

	//======================DRIVERS=================================//
	//MASTER														//
	typedef class axi_master_write_response_driver; 				//
	typedef class axi_master_write_data_driver;						//
	typedef class axi_master_write_address_driver;					//
	typedef class axi_master_write_main_driver;						//
	typedef class axi_master_write_base_driver;						//
	typedef class axi_master_write_driver;							//
	typedef class axi_master_write_sequencer;						//
	typedef class axi_master_write_base_driver_delays;				//
	typedef class axi_master_write_base_driver_ready_default_value; //
																	//
	//SLAVE 														//
	typedef class axi_slave_write_agent;							//
	typedef class axi_slave_write_response_driver;					//
	typedef class axi_slave_write_data_driver;						//
	typedef class axi_slave_write_address_driver;					//
	typedef class axi_slave_write_main_driver;						//
	typedef class axi_slave_write_base_driver;						//
	typedef class axi_slave_write_driver;							//
	typedef class axi_slave_write_sequencer;						//
	typedef class axi_slave_write_base_driver_delays;				//
	//=====================END DRIVERS==============================//

	//=====================MONITORS=================================//
	// MASTER														//
	typedef class axi_master_write_main_monitor;					//
	typedef class axi_master_write_data_collector;					//
	typedef class axi_master_write_address_collector;				//
	typedef class axi_master_write_response_collector;				//
	typedef class axi_master_write_base_collector;					//
	typedef class axi_master_write_checker;							//
	//SLAVE															//
	typedef class axi_slave_write_main_monitor;						//
	typedef class axi_slave_write_data_collector;					//
	typedef class axi_slave_write_address_collector;				//
	typedef class axi_slave_write_response_collector;				//
	typedef class axi_slave_write_base_collector;					//
	typedef class axi_slave_write_checker;							//
	//==================END MONITORS================================//

	//confing and frames
	typedef class axi_master_config;
	typedef class axi_slave_config;
	typedef class axi_config;
	typedef class axi_frame;
	typedef class slave_config_factory;
	typedef class axi_slave_config_memory_field;
	typedef class axi_slave_config_memory;

	// axi_mssg
	typedef class axi_slave_response;
	typedef class axi_waiting_resp;
	typedef class unique_id_struct;
	typedef class axi_mssg;
	typedef class axi_address_queue;
	typedef class axi_address_calc;
`endif

`ifdef andrea
	`ifdef andrea_test
		typedef class axi_read_test_config;
	`endif
	// frames
	typedef class axi_read_single_frame;
	typedef class axi_read_burst_frame;
	typedef class axi_read_base_frame;
	typedef class axi_read_whole_burst;
	typedef class axi_read_single_addr;

	typedef class ready_randomization;

	// config
	typedef class axi_master_config;
	typedef class axi_slave_config;
	typedef class axi_config;
	typedef class slave_config_factory;
	typedef class axi_slave_config_memory_field;
	typedef class axi_slave_config_memory;

	// utils
	typedef class axi_slave_read_arbitration;
	typedef class axi_master_read_response;
	typedef class axi_slave_response;
	typedef class axi_slave_memory_response;
	typedef class axi_address_calc;
	typedef class axi_address_queue;

	// slave
	typedef class axi_slave_read_driver;
	typedef class axi_slave_read_sequencer;
	typedef class axi_slave_read_agent;
	typedef class axi_slave_read_coverage_collector;
	typedef class axi_slave_read_collector;
	typedef class axi_slave_read_monitor;

	// master
	typedef class axi_master_read_driver;
	typedef class axi_master_read_sequencer;
	typedef class axi_master_read_agent;
	typedef class axi_master_read_coverage_collector;
	typedef class axi_master_read_collector;
	typedef class axi_master_read_monitor;

	// top
	typedef class axi_env;
	typedef class axi_virtual_sequencer;

	typedef class axi_master_read_transfer_seq;
	typedef class axi_master_read_multiple_addr;

`endif

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	`include "sv/axi_types.sv"

	`include "sv/axi_frame.sv"
	`include "sv/axi_config.sv"

`ifdef tome_test

	 // ======================DRIVER UTILS==============================
	 // COMMON
 	`include "sv/utils/axi_mssg.sv"
 	`include "sv/utils/axi_address_calc.sv"
	 // MASTER
	`include "sv/utils/axi_master_write_driver/base_driver.sv"
	`include "sv/utils/axi_master_write_driver/main_driver.sv"
	`include "sv/utils/axi_master_write_driver/data_driver.sv"
	`include "sv/utils/axi_master_write_driver/address_driver.sv"
	`include "sv/utils/axi_master_write_driver/response_driver.sv"
	`include "sv/utils/axi_master_write_scheduler/scheduler_packages.sv"
	`include "sv/utils/axi_master_write_scheduler/scheduler.sv"
	// SLAVE
	`include "sv/utils/axi_slave_write_driver/base_driver.sv"
	`include "sv/utils/axi_slave_write_driver/main_driver.sv"
	`include "sv/utils/axi_slave_write_driver/data_driver.sv"
	`include "sv/utils/axi_slave_write_driver/address_driver.sv"
	`include "sv/utils/axi_slave_write_driver/response_driver.sv"
	`include "sv/utils/axi_slave_config_memory.sv"
	// =================== END DRIVER UTILS==============================




	// ==================== MONITOR UTILS ==============================
	// MASTER
	`include "sv/utils/axi_master_write_monitor/address_collector.sv"
	`include "sv/utils/axi_master_write_monitor/data_collector.sv"
	`include "sv/utils/axi_master_write_monitor/response_collector.sv"
	`include "sv/utils/axi_master_write_monitor/base_collector.sv"
	`include "sv/utils/axi_master_write_monitor/coverage.sv"
	`include "sv/utils/axi_master_write_monitor/checker.sv"
	// SLAVE
	`include "sv/utils/axi_slave_write_monitor/address_collector.sv"
	`include "sv/utils/axi_slave_write_monitor/data_collector.sv"
	`include "sv/utils/axi_slave_write_monitor/response_collector.sv"
	`include "sv/utils/axi_slave_write_monitor/base_collector.sv"
	`include "sv/utils/axi_slave_write_monitor/coverage.sv"
	`include "sv/utils/axi_slave_write_monitor/checker.sv"
	//==================== END MONITOR UTILS=============================



	//add include for master
	`include "sv/master/axi_master_config.sv"
	`include "sv/master/axi_master_write_agent.sv"
	`include "sv/master/axi_master_write_driver.sv"
	`include "sv/master/axi_master_write_monitor.sv"
	`include "sv/master/axi_master_write_sequencer.sv"
	`include "sv/master/axi_master_write_sequence_lib.sv"

	//add include for slave
	`include "sv/slave/axi_slave_config.sv"
	`include "sv/slave/axi_slave_write_driver.sv"
	`include "sv/slave/axi_slave_write_sequencer.sv"
	`include "sv/slave/axi_slave_write_agent.sv"
	`include "sv/slave/axi_slave_write_monitor.sv"
//	`include "sv/slave/axi_slave_write_sequence_lib.sv"

`ifdef testing_includes
	`include "axi_write_test/axi_master_write_test_config.sv"
	`include "axi_write_test/axi_master_write_test_env.sv"
	`include "axi_write_test/axi_write_test_tb.sv"
	`include "axi_write_test/axi_master_write_test_lib.sv"


`endif
`endif

//	`include "sv/slave/axi_slave_write_driver.sv"
//	`include "sv/slave/axi_slave_write_monitor.sv"
//	`include "sv/slave/axi_slave_write_sequencer.sv"
//	`include "sv/slave/axi_slave_write_sequence_lib.sv"

//	`include "sv/slave/axi_slave_read_driver.sv"
//	`include "sv/slave/axi_slave_read_sequencer.sv"
//	`include "sv/slave/axi_slave_read_sequence_lib.sv"

`ifdef andrea
	`ifdef andrea_test
		`include "axi_read_test_config.sv"
		`include "axi_read_tb.sv"
	`endif

	`include "sv/axi_env.sv"

	`include "sv/axi_read_frames.sv"

	// add include for master
	`include "sv/master/axi_master_config.sv"

	`include "sv/master/axi_master_read_driver.sv"
	`include "sv/master/axi_master_read_coverage_collector.sv"
	`include "sv/master/axi_master_read_sequencer.sv"
	`include "sv/master/axi_master_read_sequence_lib.sv"
	`include "sv/master/axi_master_read_agent.sv"
	`include "sv/master/axi_master_read_collector.sv"
	`include "sv/master/axi_master_read_monitor.sv"

	// add include for slave
	`include "sv/slave/axi_slave_config.sv"

	`include "sv/slave/axi_slave_read_driver.sv"
	`include "sv/slave/axi_slave_read_coverage_collector.sv"
	`include "sv/slave/axi_slave_read_sequencer.sv"
	`include "sv/slave/axi_slave_read_sequence_lib.sv"
	`include "sv/slave/axi_slave_read_agent.sv"
	`include "sv/slave/axi_slave_read_monitor.sv"
	`include "sv/slave/axi_slave_read_collector.sv"

	// utils
	`include "sv/utils/axi_master_read_response.sv"
	`include "sv/utils/axi_slave_read_arbitration.sv"
	`include "sv/utils/axi_mssg.sv"
	`include "sv/utils/axi_slave_config_memory.sv"
	`include "sv/utils/axi_address_calc.sv"

	`include "sv/axi_virtual_sequencer.sv"
	`include "sv/axi_virtual_seq_lib.sv"

`endif


endpackage : axi_pkg


`endif