`ifndef REGISTER_MODEL_ENV_PKG_SVH
`define REGISTER_MODEL_ENV_PKG_SVH

// Include interface

package register_model_env_pkg;

	typedef class axi_read_wrapper_agent;
	typedef class axi_read_wrapper_top_sequencer;
	typedef class axi_read_wrapper_low_sequencer;
	typedef class axi_read_wrapper_monitor;
	typedef class axi_read_wrapper_sequence;

	typedef class axi_write_wrapper_agent;
	typedef class axi_write_wrapper_top_sequencer;
	typedef class axi_write_wrapper_low_sequencer;
	typedef class axi_write_wrapper_monitor;
	typedef class axi_write_wrapper_sequence;

	typedef class dut_register_model_lower_sequence;
	typedef class dut_register_model_lower_sequencer;
	typedef class dut_register_model_top_monitor;
	typedef class dut_register_model_top_sequencer;

	typedef class dut_register_model_config;
	typedef class dut_register_model_env;
	typedef class dut_register_model_tb;
	typedef class dut_register_model_test_base;

	typedef class dut_register_model_test_sequence;
	typedef class dut_tesgin_logger_test_sequence;

	typedef	class dut_testing_logger_package;
	typedef class dut_testing_logger;


	import uvm_pkg::*;
	`include "uvm_macros.svh"

	`include "axi_uvc/sv/axi_pkg.sv"
	import axi_pkg::*;
//
	`include "dut_register_layer/sv/dut_register_model_pkg.sv"
	import dut_register_model_pkg::*;

	`include "dut_testing/sv/agents_wrappers/read_wrapper/read_wrapper_agent.sv"
	`include "dut_testing/sv/agents_wrappers/read_wrapper/read_wrapper_low_sequencer.sv"
	`include "dut_testing/sv/agents_wrappers/read_wrapper/read_wrapper_top_sequencer.sv"
	`include "dut_testing/sv/agents_wrappers/read_wrapper/read_wrapper_sequence.sv"
	`include "dut_testing/sv/agents_wrappers/read_wrapper/read_wrapper_monitor.sv"

	`include "dut_testing/sv/agents_wrappers/write_wrapper/write_wrapper_agent.sv"
	`include "dut_testing/sv/agents_wrappers/write_wrapper/write_wrapper_low_sequencer.sv"
	`include "dut_testing/sv/agents_wrappers/write_wrapper/write_wrapper_top_sequencer.sv"
	`include "dut_testing/sv/agents_wrappers/write_wrapper/write_wrapper_monitor.sv"
	`include "dut_testing/sv/agents_wrappers/write_wrapper/write_wrapper_sequence.sv"


	`include "dut_testing/sv/layering/lower_sequencer.sv"
	`include "dut_testing/sv/layering/lower_sequence.sv"
	`include "dut_testing/sv/layering/top_sequencer.sv"
	`include "dut_testing/sv/layering/top_monitor.sv"

	`include "dut_testing/sv/test_tb/config.sv"
	`include "dut_testing/sv/test_tb/env.sv"
	`include "dut_testing/sv/test_tb/tb.sv"
	`include "dut_testing/sv/test_tb/test.sv"
//	`include "dut_testing/sv/test_tb/top.sv"

	`include "dut_testing/sv/utils/logger.sv"


	//test
	`include "dut_testing/testing/sequences/dut_register_model_base_sequence.sv"

endpackage


`endif
