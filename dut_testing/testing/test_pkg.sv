`ifndef DUT_TESTING_TEST_AND_SEQS_PKG_SV
`define DUT_TESTING_TEST_AND_SEQS_PKG_SV

package dut_testing_test_and_seqs_pkg;

// ========================= TESTS =========================
	typedef class dut_register_model_test_base;
	typedef class count_test;
	typedef class match_test;
	typedef class swreset_test;
	typedef class iir_test;
	typedef class load_test;
	typedef class mis_test;
	typedef class combined_test;
// =========================================================

// ======================= SEQUENCES =======================
	typedef class dut_register_model_test_sequence;
	typedef class dut_register_model_base_sequence;
	typedef class dut_tesgin_logger_test_sequence;
	typedef class count_seq;
	typedef class swreset_seq;
	typedef class match_seq;
	typedef class iir_seq;
	typedef class load_seq;
	typedef class mis_seq;
// =========================================================

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	`include "axi_uvc/sv/axi_pkg.sv"
	import axi_pkg::*;

	`include "dut_register_layer/sv/dut_register_model_pkg.sv"
	import dut_register_model_pkg::*;

	`include "dut_testing/sv/register_model_env_pkg.sv"
	import register_model_env_pkg::*;


// ========================= TESTS =========================
	`include "dut_testing/testing/tests/test.sv"
	`include "dut_testing/testing/tests/count_test.sv"
	`include "dut_testing/testing/tests/match_test.sv"
	`include "dut_testing/testing/tests/swreset_test.sv"
	`include "dut_testing/testing/tests/iir_test.sv"
	`include "dut_testing/testing/tests/load_test.sv"
	`include "dut_testing/testing/tests/mis_test.sv"
	`include "dut_testing/testing/tests/combined_test.sv"
// =========================================================

// ======================= SEQUENCES =======================
	`include "dut_testing/testing/sequences/dut_register_model_base_sequence.sv"
	`include "dut_testing/testing/sequences/count_seq.sv"
	`include "dut_testing/testing/sequences/swreset_seq.sv"
	`include "dut_testing/testing/sequences/match_seq.sv"
	`include "dut_testing/testing/sequences/iir_seq.sv"
	`include "dut_testing/testing/sequences/load_seq.sv"
	`include "dut_testing/testing/sequences/mis_seq.sv"
// =========================================================

endpackage

`endif