`ifndef AXI_PKG_SVH
`define AXI_PKG_SVH

`define tome_test
`define testing_includes
`define andrea

package axi_pkg;
	`ifdef tome_test




	`ifdef testing_includes
	typedef class axi_write_test_config;
	typedef class axi_master_write_env;

	`endif
	//scheduler and packages
	typedef class axi_master_write_scheduler;
	typedef class axi_master_write_scheduler_packages;
	typedef class axi_master_write_scheduler2_0;
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
	typedef class axi_master_write_coverage_base;					//
	typedef class axi_master_write_checker_base;					//
  	typedef class axi_master_write_checker_map;
  	typedef class axi_master_write_coverage_map;
	typedef class axi_master_write_burst_collector;
	//SLAVE															//
	typedef class axi_slave_write_main_monitor;						//
	typedef class axi_slave_write_data_collector;					//
	typedef class axi_slave_write_address_collector;				//
	typedef class axi_slave_write_response_collector;				//
	typedef class axi_slave_write_base_collector;					//
	typedef class axi_slave_write_checker;
	typedef class axi_slave_write_coverage_base;					//
	typedef class axi_slave_write_checker_base;						//
  	typedef class axi_slave_write_checker_map;
  	typedef class axi_slave_write_coverage_map;
	typedef class axi_slave_write_burst_collector;
	//==================END MONITORS================================//


	//==================CONFIGURATIONS==============================
	typedef class axi_depth_config;
	typedef class axi_write_config_field;
	typedef class axi_write_configuration_register;
	typedef class axi_write_master_user_configuration;
	typedef class axi_write_conf;
	typedef class axi_write_buss_write_configuration;
	typedef class axi_write_buss_read_configuration;
	typedef class axi_master_write_correct_incorrect_value_randomization;
	typedef class axi_write_global_conf;
	typedef class axi_write_correct_value_conf;
	typedef class axi_master_write_correct_incorrect_random;
	typedef class axi_write_correct_one_value;
	//=================END CONFIGURATIONS===========================


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
	//typedef class axi_address_calc;
`endif

`ifdef andrea

	// ==================== FRAMES ==============================
	typedef class axi_read_single_frame;
	typedef class axi_read_burst_frame;
	typedef class axi_read_base_frame;
	typedef class axi_read_whole_burst;
	typedef class axi_read_single_addr;

	typedef class ready_randomization;
	// ==========================================================

	// ==================== CONFIG ==============================
	typedef class axi_master_config;
	typedef class axi_slave_config;
	typedef class axi_config;
	typedef class slave_config_factory;
	typedef class axi_slave_config_memory_field;
	typedef class axi_slave_config_memory;
	// ==========================================================

	// ==================== UTILS ===============================
	typedef class axi_slave_read_arbitration;
	typedef class axi_master_read_response;
	typedef class axi_slave_response;
	typedef class axi_slave_memory_response;
	typedef class axi_address_calc;
	typedef class axi_address_queue;
	// ==========================================================

	// ==================== SLAVE ===============================
	typedef class axi_slave_read_driver;
	typedef class axi_slave_read_sequencer;
	typedef class axi_slave_read_agent;
	typedef class axi_slave_read_coverage_collector;
	typedef class axi_slave_read_collector;
	typedef class axi_slave_read_monitor;
	// ==========================================================

	// ==================== MASTER ==============================
	typedef class axi_master_read_driver;
	typedef class axi_master_read_sequencer;
	typedef class axi_master_read_agent;
	typedef class axi_master_read_coverage_collector;
	typedef class axi_master_read_collector;
	typedef class axi_master_read_monitor;
	// ==========================================================

	// ==================== TOP ==================================
	typedef class axi_read_env;
	typedef class axi_virtual_sequencer;

	typedef class axi_master_read_multiple_addr;
	typedef class axi_master_read_no_err_count;
	typedef class axi_master_read_dut_counter_seq;
	// ==========================================================

`endif

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	`include "axi_uvc/sv/axi_types.sv"

	`include "axi_uvc/sv/axi_frame.sv"
	`include "axi_uvc/sv/axi_config.sv"

`ifdef tome_test

	 // ======================DRIVER UTILS==============================
	 // COMMON
 	`include "axi_uvc/sv/utils/axi_mssg.sv"
 	//`include "axi_uvc/sv/utils/axi_address_calc.sv"
	 // MASTER
	`include "axi_uvc/sv/utils/axi_master_write_driver/base_driver.sv"
	`include "axi_uvc/sv/utils/axi_master_write_driver/main_driver.sv"
	`include "axi_uvc/sv/utils/axi_master_write_driver/data_driver.sv"
	`include "axi_uvc/sv/utils/axi_master_write_driver/address_driver.sv"
	`include "axi_uvc/sv/utils/axi_master_write_driver/response_driver.sv"
	`include "axi_uvc/sv/utils/axi_master_write_scheduler/scheduler_packages.sv"
	`include "axi_uvc/sv/utils/axi_master_write_scheduler/scheduler.sv"
	`include "axi_uvc/sv/utils/axi_master_write_scheduler/scheduler_package2_0.sv"
	`include "axi_uvc/sv/utils/axi_master_write_scheduler/scheduler2_0.sv"
	// SLAVE
	`include "axi_uvc/sv/utils/axi_slave_write_driver/base_driver.sv"
	`include "axi_uvc/sv/utils/axi_slave_write_driver/main_driver.sv"
	`include "axi_uvc/sv/utils/axi_slave_write_driver/data_driver.sv"
	`include "axi_uvc/sv/utils/axi_slave_write_driver/address_driver.sv"
	`include "axi_uvc/sv/utils/axi_slave_write_driver/response_driver.sv"
	`include "axi_uvc/sv/utils/axi_slave_config_memory.sv"
	// =================== END DRIVER UTILS==============================




	// ==================== MONITOR UTILS ==============================
	// MASTER
	`include "axi_uvc/sv/utils/axi_master_write_monitor/address_collector.sv"
	`include "axi_uvc/sv/utils/axi_master_write_monitor/data_collector.sv"
	`include "axi_uvc/sv/utils/axi_master_write_monitor/response_collector.sv"
	`include "axi_uvc/sv/utils/axi_master_write_monitor/base_collector.sv"
	`include "axi_uvc/sv/utils/axi_master_write_monitor/burst_collector.sv"
	//COVERAGES
	`include "axi_uvc/sv/utils/axi_master_write_monitor/coverage_base.sv"
	`include "axi_uvc/sv/utils/axi_master_write_monitor/coverages/coverage.sv"
	`include "axi_uvc/sv/utils/axi_master_write_monitor/coverages/create_coverage.sv"
	//CHECKERS
	`include "axi_uvc/sv/utils/axi_master_write_monitor/checker_base.sv"
	`include "axi_uvc/sv/utils/axi_master_write_monitor/checkers/checker.sv"
	`include "axi_uvc/sv/utils/axi_master_write_monitor/checkers/create_checker.sv"

	 //SLAVE
	`include "axi_uvc/sv/utils/axi_slave_write_monitor/address_collector.sv"
	`include "axi_uvc/sv/utils/axi_slave_write_monitor/data_collector.sv"
	`include "axi_uvc/sv/utils/axi_slave_write_monitor/response_collector.sv"
	`include "axi_uvc/sv/utils/axi_slave_write_monitor/base_collector.sv"
	`include "axi_uvc/sv/utils/axi_slave_write_monitor/burst_collector.sv"
	//COVERAGES
	`include "axi_uvc/sv/utils/axi_slave_write_monitor/coverage_base.sv"
	`include "axi_uvc/sv/utils/axi_slave_write_monitor/coverages/coverage.sv"
	`include "axi_uvc/sv/utils/axi_slave_write_monitor/coverages/create_coverage.sv"
	//CHECKERS
	`include "axi_uvc/sv/utils/axi_slave_write_monitor/checker_base.sv"
	`include "axi_uvc/sv/utils/axi_slave_write_monitor/checkers/checker.sv"
	`include "axi_uvc/sv/utils/axi_slave_write_monitor/checkers/create_checker.sv"
	//==================== END MONITOR UTILS=============================


	//==================CONFIGURATIONS==============================
	`include "axi_uvc/sv/utils/configuration/configuration_objects.sv"
	`include "axi_uvc/sv/utils/configuration/write_configuration_base.sv"
	`include "axi_uvc/sv/utils/configuration/write_configuration_wrapper.sv"
	`include "axi_uvc/configurations/register_configuration.sv"
	`include "axi_uvc/configurations/write_user_configuration.sv"
	`include "axi_uvc/sv/utils/axi_master_write_scheduler/correct_incorrect_value_randomization.sv"
	//=================END CONFIGURATIONS===========================


	//add include for master
	`include "axi_uvc/sv/master/axi_master_config.sv"
	`include "axi_uvc/sv/master/axi_master_write_agent.sv"
	`include "axi_uvc/sv/master/axi_master_write_driver.sv"
	`include "axi_uvc/sv/master/axi_master_write_monitor.sv"
	`include "axi_uvc/sv/master/axi_master_write_sequencer.sv"
	`include "axi_uvc/sv/master/axi_master_write_sequence_lib.sv"

	//add include for slave
	`include "axi_uvc/sv/slave/axi_slave_config.sv"
	`include "axi_uvc/sv/slave/axi_slave_write_driver.sv"
	`include "axi_uvc/sv/slave/axi_slave_write_sequencer.sv"
	`include "axi_uvc/sv/slave/axi_slave_write_agent.sv"
	`include "axi_uvc/sv/slave/axi_slave_write_monitor.sv"


//	`include "axi_uvc/sv/slave/axi_slave_write_sequence_lib.sv"

`ifdef testing_includes
	`include "axi_uvc/dev_test/axi_write_test/axi_master_write_test_config.sv"
	`include "axi_uvc/dev_test/axi_write_test/axi_master_write_test_env.sv"
	`include "axi_uvc/dev_test/axi_write_test/axi_write_test_tb.sv"
	`include "axi_uvc/dev_test/axi_write_test/axi_master_write_test_lib.sv"


`endif
`endif

//	`include "axi_uvc/sv/slave/axi_slave_write_driver.sv"
//	`include "axi_uvc/sv/slave/axi_slave_write_monitor.sv"
//	`include "axi_uvc/sv/slave/axi_slave_write_sequencer.sv"
//	`include "axi_uvc/sv/slave/axi_slave_write_sequence_lib.sv"

//	`include "axi_uvc/sv/slave/axi_slave_read_driver.sv"
//	`include "axi_uvc/sv/slave/axi_slave_read_sequencer.sv"
//	`include "axi_uvc/sv/slave/axi_slave_read_sequence_lib.sv"

`ifdef andrea

	// ==================== MASTER ==============================
	`include "axi_uvc/sv/master/axi_master_config.sv"
	`include "axi_uvc/sv/master/axi_master_read_driver.sv"
	`include "axi_uvc/sv/master/axi_master_read_coverage_collector.sv"
	`include "axi_uvc/sv/master/axi_master_read_sequencer.sv"
	`include "axi_uvc/sv/master/axi_master_read_sequence_lib.sv"
	`include "axi_uvc/sv/master/axi_master_read_agent.sv"
	`include "axi_uvc/sv/master/axi_master_read_collector.sv"
	`include "axi_uvc/sv/master/axi_master_read_monitor.sv"
	// ==========================================================

	// ==================== SLAVE ===============================
	`include "axi_uvc/sv/slave/axi_slave_config.sv"
	`include "axi_uvc/sv/slave/axi_slave_read_driver.sv"
	`include "axi_uvc/sv/slave/axi_slave_read_coverage_collector.sv"
	`include "axi_uvc/sv/slave/axi_slave_read_sequencer.sv"
	`include "axi_uvc/sv/slave/axi_slave_read_sequence_lib.sv"
	`include "axi_uvc/sv/slave/axi_slave_read_agent.sv"
	`include "axi_uvc/sv/slave/axi_slave_read_monitor.sv"
	`include "axi_uvc/sv/slave/axi_slave_read_collector.sv"
	// ==========================================================

	// ==================== UTILS ===============================
	`include "axi_uvc/sv/utils/axi_master_read_response.sv"
	`include "axi_uvc/sv/utils/axi_slave_read_arbitration.sv"
	`include "axi_uvc/sv/utils/axi_mssg.sv"
	`include "axi_uvc/sv/utils/axi_slave_config_memory.sv"
	`include "axi_uvc/sv/utils/axi_address_calc.sv"
	// ==========================================================

	// ==================== TOP =================================
	`include "axi_uvc/sv/axi_virtual_sequencer.sv"
	`include "axi_uvc/sv/axi_virtual_seq_lib.sv"
	`include "axi_uvc/sv/axi_read_env.sv"
	`include "axi_uvc/sv/axi_read_frames.sv"
	// ==========================================================

`endif

endpackage : axi_pkg

`endif