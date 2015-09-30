`ifndef DUT_REGISTER_MODLE_PKG_SVH
`define DUT_REGISTER_MODLE_PKG_SVH



//`include "dut_register_abstract_layer/dut_if.sv";

package dut_register_model_pkg;

	typedef class dut_register_model_adapter;
	typedef class RIS;
	typedef class IM;
	typedef class MIS;
	typedef class MIS_overflow_cb;
	typedef class MIS_underflow_cb;
	typedef class MIS_match_cb;
	typedef class LOAD;
	typedef class CFG;
	typedef class SWRESET;
	typedef class SWRESET_reset_passcode_cb;
	typedef class IIR;
	typedef class IIR_interrupt_priority_cb;
	typedef class MATCH;
	typedef class COUNT;
	typedef class dut_register_block;
	typedef class dut_frame;

	//includes from uvc
	//typedef class axi_frame;

	`include "sv/axi_pkg.sv"
	import axi_pkg::*;

	import uvm_pkg::*;
	`include "uvm_macros.svh"


	`include "dut_register_abstract_layer/types.sv"

	`include "dut_register_abstract_layer/register_model/adapter.sv"
	`include "dut_register_abstract_layer/register_model/frame.sv"
	`include "dut_register_abstract_layer/register_model/reference_model.sv"
	`include "dut_register_abstract_layer/register_model/register_model.sv"
//	`include "dut_register_abstract_layer/register_model/sequencer.sv"

	`include "dut_register_abstract_layer/register_model/registers_and_callbacks/RIS.sv"
	`include "dut_register_abstract_layer/register_model/registers_and_callbacks/IM.sv"
	`include "dut_register_abstract_layer/register_model/registers_and_callbacks/MIS.sv"
	`include "dut_register_abstract_layer/register_model/registers_and_callbacks/LOAD.sv"
	`include "dut_register_abstract_layer/register_model/registers_and_callbacks/CFG.sv"
	`include "dut_register_abstract_layer/register_model/registers_and_callbacks/SWRESET.sv"
	`include "dut_register_abstract_layer/register_model/registers_and_callbacks/IIR.sv"
	`include "dut_register_abstract_layer/register_model/registers_and_callbacks/MATCH.sv"
	`include "dut_register_abstract_layer/register_model/registers_and_callbacks/COUNT.sv"


//	`include "sv/axi_frame.sv"


endpackage


`endif