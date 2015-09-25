/******************************************************************************
* DVT CODE TEMPLATE: top package
* Created by root on Sep 23, 2015
* uvc_company = uvc_company, uvc_name = uvc_name uvc_if = uvc_if
*******************************************************************************/

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


	import uvm_pkg::*;
	`include "uvm_macros.svh"

	`include "sv/axi_pkg.sv"
	import axi_pkg::*;
//
	`include "dut_register_abstract_layer/dut_register_model_pkg.sv"
	import dut_register_model_pkg::*;

	`include "dut_test_env_register_model/agents_wrappers/read_wrapper/read_wrapper_agent.sv"
	`include "dut_test_env_register_model/agents_wrappers/read_wrapper/read_wrapper_low_sequencer.sv"
	`include "dut_test_env_register_model/agents_wrappers/read_wrapper/read_wrapper_top_sequencer.sv"
	`include "dut_test_env_register_model/agents_wrappers/read_wrapper/read_wrapper_sequence.sv"
	`include "dut_test_env_register_model/agents_wrappers/read_wrapper/read_wrapper_monitor.sv"

	`include "dut_test_env_register_model/agents_wrappers/write_wrapper/write_wrapper_agent.sv"
	`include "dut_test_env_register_model/agents_wrappers/write_wrapper/write_wrapper_low_sequencer.sv"
	`include "dut_test_env_register_model/agents_wrappers/write_wrapper/write_wrapper_top_sequencer.sv"
	`include "dut_test_env_register_model/agents_wrappers/write_wrapper/write_wrapper_monitor.sv"
	`include "dut_test_env_register_model/agents_wrappers/write_wrapper/write_wrapper_sequence.sv"


	`include "dut_test_env_register_model/layering/lower_sequencer.sv"
	`include "dut_test_env_register_model/layering/lower_sequence.sv"
	`include "dut_test_env_register_model/layering/top_sequencer.sv"
	`include "dut_test_env_register_model/layering/top_monitor.sv"

	`include "dut_test_env_register_model/test_tb/config.sv"
	`include "dut_test_env_register_model/test_tb/env.sv"
	`include "dut_test_env_register_model/test_tb/tb.sv"
	`include "dut_test_env_register_model/test_tb/test.sv"
//	`include "dut_test_env_register_model/test_tb/top.sv"


	//test
	`include "dut_test_env_register_model/tests/dut_register_model_base_sequence.sv"



endpackage
