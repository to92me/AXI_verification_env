`ifndef AXI_IF
`define AXI_IF

//-------------------------------------------------------------------------
//
// INTERFACE: axi_if
//
//-------------------------------------------------------------------------

import uvm_pkg::*;            // import the UVM library
`include "uvm_macros.svh"     // Include the UVM macros

interface axi_if (input sig_reset, input sig_clock);

	parameter ADDR_WIDTH = 32;
	parameter DATA_WIDTH = 64;
	parameter ID_WIDTH = 32;

	//parameter ADDR_WIDTH = 32;	// Width of the address bus
	//parameter DATA_WIDTH = 64;	// Width of the system data buses
	parameter RID_WIDTH = 4;	// Number of read channel ID bits required.
	parameter WID_WIDTH = 4;	// Number of write channel ID bits required.
	parameter MAXRBURSTS = 16;	// Size of FIFOs for storing outstanding read bursts. This must be greater than or equal to the maximum number of outstanding read bursts that can be active at the slave interface
	parameter MAXWBURSTS = 16;	// Size of FIFOs for storing outstanding write bursts. This must be greater than or equal to the maximum number of outstanding write bursts that can be active at the slave interface.
	parameter EXMON_WIDTH = 4;	// Width of the exclusive access monitor required
	parameter AWUSER_WIDTH = 32;	// Width of the user AW sideband field
	parameter WUSER_WIDTH = 32;	// Width of the user W sideband field
	parameter BUSER_WIDTH = 32;	// Width of the user B sideband field
	parameter ARUSER_WIDTH = 32;	// Width of the user AR sideband field
	parameter RUSER_WIDTH = 32;	// Width of the user R sideband field

	// performance checking
	parameter MAXWAITS = 16;	// Maximum number of cycles between VALID to READY HIGH before a warning is generated

	parameter STRB_WIDTH = DATA_WIDTH / 8;

	// write address channel signals
	logic [WID_WIDTH - 1 : 0]	awid;
	logic [ADDR_WIDTH-1 : 0]	awaddr;
	logic [7:0]					awlen;
	logic [2:0]					awsize;
	logic [1:0]					awburst;
	logic [1:0]					awlock;
	logic [3:0]					awcache;
	logic [2:0] 				awprot;
	logic [3:0]					awqos;
	logic [3:0]					awregion;
	logic [AWUSER_WIDTH-1 : 0]	awuser;
    logic 						awvalid;
	logic 						awready;

	// write data channel signals
	logic [WID_WIDTH-1 : 0]		wid;
	logic [DATA_WIDTH-1 : 0]	wdata;
	logic [STRB_WIDTH-1 : 0]	wstrb;
	logic						wlast;
	logic [WUSER_WIDTH-1 : 0]	wuser;
	logic						wvalid;
	logic						wready;

	// write response channel signals
	logic [WID_WIDTH-1 : 0]		bid;
	logic [1:0]					bresp;
	logic [BUSER_WIDTH-1 : 0]	buser;
	logic						bready;
	logic						bvalid;

	// read address channel signals
	logic [RID_WIDTH-1 : 0]		arid;
	logic [ADDR_WIDTH-1 : 0]	araddr;
	logic [7:0]					arlen;
	logic [2:0]					arsize;
	logic [1:0]					arburst;
	logic [1:0]					arlock;
	logic [3:0]					arcache;
	logic [2:0]					arprot;
	logic [3:0]					arqos;
	logic [3:0]					arregion;
	logic [ARUSER_WIDTH-1 : 0]	aruser;
	logic						arvalid;
	logic						arready;

	// read data channel signals
	logic [RID_WIDTH-1 : 0]		rid;
	logic [DATA_WIDTH-1 : 0]	rdata;
	logic [1:0]					rresp;
	logic						rlast;
	logic [RUSER_WIDTH-1 : 0]	ruser;
	logic						rvalid;
	logic						rready;


	// Control flags
	bit							has_checks = 1;
	bit							has_coverage = 1;

//------------------------------------------------------------------------------
//
// axi read vif assertions
//
//------------------------------------------------------------------------------
    // helper flags
    bit arvalid_arready_flag = 0;   // set if arvalid is HIGH and arready is LOW
    bit rvalid_rready_flag = 0; // set if rvalid is HIGH and rready is LOW
    bit reset_flag = 0; // set when reset occurs

    // catch reset signal
    always @(posedge sig_reset) begin
        reset_flag = 1;
        @(posedge sig_clock);
        reset_flag = 0;
    end

	always @(posedge sig_clock)
	begin
		// Assertion AXI4_ERRM_ARID_STABLE
		// ARID remains stable when ARVALID is asserted and ARREADY is low
		assert_AXI4_ERRM_ARID_STABLE : assert property (
			disable iff(!has_checks || !sig_reset || !arvalid_arready_flag)
			((arvalid == 1 && arready == 0) |=> $stable(arid)))
            else
            	`uvm_error("ASSERTION_ERR","AXI4_ERRM_ARID_STABLE: ARID didn't remain stable when ARVALID is asserted and ARREADY is low")

		// Assertion AXI4_ERRM_ARID_X
        // A value of X on ARID is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARID_X : assert property (
        	disable iff(!has_checks || !sig_reset)
        	(arvalid == 1 |-> !$isunknown(arid)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARID_X: A value of X on ARID is not permitted when ARVALID is HIGH")

        // Assertion AXI4_ERRM_ARADDR_STABLE
        // ARADDR remains stable when ARVALID is asserted and ARREADY is low
        assert_AXI4_ERRM_ARADDR_STABLE : assert property (
        	disable iff(!has_checks || !sig_reset || !arvalid_arready_flag)
        	((arvalid == 1 && arready == 0) |=> $stable(araddr)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARADDR_STABLE: ARADDR didn't remain stable when ARVALID is asserted and ARREADY is low")

        // Assertion AXI4_ERRM_ARADDR_X
        // A value of X on ARADDR is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARADDR_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (arvalid == 1 |-> !$isunknown(araddr)))
            else
            	`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARADDR_X: ARADDR went to X or Z when ARVALID is HIGH")

        // Assertion AXI4_ERRM_ARLEN_STABLE
        // ARLEN remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_ARLEN_STABLE : assert property (
        	disable iff(!has_checks || !sig_reset || !arvalid_arready_flag)
        	((arvalid == 1 && arready == 0) |=> $stable(arlen)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARLEN_STABLE: ARLEN didn't remain stable when ARVALID is asserted and ARREADY is low")

        // Assertion AXI4_ERRM_ARLEN_X
        // A value of X on ARLEN is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARLEN_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (arvalid == 1 |-> !$isunknown(arlen)))
            else
            	`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARLEN_X: ARLEN went to X or Z when ARVALID is HIGH")

        // Assertion AXI4_ERRM_ARSIZE_STABLE
        // ARSIZE remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_ARSIZE_STABLE : assert property (
        	disable iff(!has_checks || !sig_reset || !arvalid_arready_flag)
        	((arvalid == 1 && arready == 0) |=> $stable(arsize)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARSIZE_STABLE: ARSIZE didn't remain stable when ARVALID is asserted and ARREADY is low")

        // Assertion AXI4_ERRM_ARSIZE_X
        // A value of X on ARSIZE is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARSIZE_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (arvalid == 1 |-> !$isunknown(arsize)))
            else
            	`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARSIZE_X: ARSIZE went to X or Z when ARVALID is HIGH")

        // Assertion AXI4_ERRM_ARBURST_STABLE
        // ARBURST remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_ARBURST_STABLE : assert property (
        	disable iff(!has_checks || !sig_reset || !arvalid_arready_flag)
        	((arvalid == 1 && arready == 0) |=> $stable(arburst)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARBURST_STABLE: ARBURST didn't remain stable when ARVALID is asserted and ARREADY is low")

       	// Assertion AXI4_ERRM_ARBURST_X
        // A value of X on ARBURST is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARBURST_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (arvalid == 1 |-> !$isunknown(arburst)))
            else
            	`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARBURST_X: ARBURST went to X or Z when ARVALID is HIGH")

        // Assertion AXI4_ERRM_ARLOCK_STABLE
        // ARLOCK remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_ARLOCK_STABLE : assert property (
        	disable iff(!has_checks || !sig_reset || !arvalid_arready_flag)
        	((arvalid == 1 && arready == 0) |=> $stable(arlock)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARLOCK_STABLE: ARLOCK didn't remain stable when ARVALID is asserted and ARREADY is low")

       	// Assertion AXI4_ERRM_ARLOCK_X
        // A value of X on ARLOCK is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARLOCK_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (arvalid == 1 |-> !$isunknown(arlock)))
            else
            	`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARLOCK_X: ARLOCK went to X or Z when ARVALID is HIGH")

        // Assertion AXI4_ERRM_ARCACHE_STABLE
        // ARCACHE remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_ARCACHE_STABLE : assert property (
        	disable iff(!has_checks || !sig_reset || !arvalid_arready_flag)
        	((arvalid == 1 && arready == 0) |=> $stable(arcache)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARCACHE_STABLE: ARCACHE didn't remain stable when ARVALID is asserted and ARREADY is low")

        // Assertion AXI4_ERRM_ARCACHE_X
        // A value of X on ARCACHE is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARCACHE_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (arvalid == 1 |-> !$isunknown(arcache)))
            else
            	`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARCACHE_X: ARCACHE went to X or Z when ARVALID is HIGH")

        // Assertion AXI4_ERRM_ARPROT_STABLE
        // ARPROT remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_ARPROT_STABLE : assert property (
        	disable iff(!has_checks || !sig_reset || !arvalid_arready_flag)
        	((arvalid == 1 && arready == 0) |=> $stable(arprot)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARPROT_STABLE: ARPROT didn't remain stable when ARVALID is asserted and ARREADY is low")

       	// Assertion AXI4_ERRM_ARPROT_X
        // A value of X on ARPROT is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARPROT_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (arvalid == 1 |-> !$isunknown(arprot)))
            else
            	`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARPROT_X: ARPROT went to X or Z when ARVALID is HIGH")

        // Assertion AXI4_ERRM_ARVALID_RESET
        // ARVALID is low for the first cycle after ARESETn goes HIGH
        assert_AXI4_ERRM_ARVALID_RESET : assert property (
        	disable iff(!has_checks || !sig_reset)
        	(reset_flag == 1 |-> (arvalid == 0)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARVALID_RESET: ARVALID not low for the first cycle after ARESETn goes HIGH")

        // Assertion AXI4_ERRM_ARVALID_STABLE
        // When ARVALID is asserted, then it remains asserted until ARREADY is HIGH
       	assert_AXI4_ERRM_ARVALID_STABLE : assert property (
       		disable iff(!has_checks || !sig_reset)
       		(if (arvalid == 1)
                !arready |-> arvalid))
       		else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARVALID_STABLE: ARVALID was asserted, but it didn't remain asserted until ARREADY is HIGH")

       	// Assertion AXI4_ERRM_ARVALID_X
        // A value of X on ARVALID is not permitted when not in reset
       	assert_AXI4_ERRM_ARVALID_X : assert property (
        	disable iff(!has_checks || !sig_reset)
        	(sig_reset == 0 |-> !$isunknown(arvalid)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARVALID_X: ARVALID went to X or Z when not in reset")

        // Assertion AXI4_ERRS_ARREADY_X
       	// A value of X on ARREADY is not permitted when not in reset
       	assert_AXI4_ERRM_ARREADY_X : assert property (
        	disable iff(!has_checks || !sig_reset)
        	(sig_reset == 0 |-> !$isunknown(arready)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARREADY_X: ARREADY went to X or Z when not in reset")

        // Assertion AXI4_RECS_ARREADY_MAX_WAIT
       	// Recommended that ARREADY is asserted within MAXWAITS cycles of ARVALID being asserted
        assert_AXI4_RECS_ARREADY_MAX_WAIT : assert property (
            disable iff(!has_checks || !sig_reset)
            (arvalid |-> ##[0:MAXWAITS]arready))
            else
                `uvm_warning("ASSERTION_WARNING", "AXI4_RECS_ARREADY_MAX_WAIT: ARREADY is not asserted within MAXWAITS cycles of ARVALID being asserted")

        // Assertion AXI4_ERRM_ARUSER_STABLE
        // ARUSER remains stable when ARVALID is asserted, and ARREADY is LOW
        assert_AXI4_ERRM_ARUSER_STABLE : assert property (
        	disable iff(!has_checks || !sig_reset || !arvalid_arready_flag)
        	((arvalid == 1 && arready == 0) |=> $stable(aruser)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARUSER_STABLE: ARUSER didn't remain stable when ARVALID is asserted and ARREADY is low")

        // Assertion AXI4_ERRM_ARUSER_X
        // A value of X on ARUSER is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARUSER_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (arvalid == 1 |-> !$isunknown(aruser)))
            else
            	`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARUSER_X: ARUSER went to X or Z when ARVALID is HIGH")

        // Assertion AXI4_ERRM_ARQOS_STABLE
        // ARQOS remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_ARQOS_STABLE : assert property (
        	disable iff(!has_checks || !sig_reset || !arvalid_arready_flag)
        	((arvalid == 1 && arready == 0) |=> $stable(arqos)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARQOS_STABLE: ARQOS didn't remain stable when ARVALID is asserted and ARREADY is low")

      	// Assertion AXI4_ERRM_ARQOS_X
        // A value of X on ARQOS is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARQOS_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (arvalid == 1 |-> !$isunknown(arqos)))
            else
            	`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARQOS_X: ARQOS went to X or Z when ARVALID is HIGH")

        // Assertion AXI4_ERRM_ARREGION_STABLE
        // ARREGION remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_ARREGION_STABLE : assert property (
        	disable iff(!has_checks || !sig_reset || !arvalid_arready_flag)
        	((arvalid == 1 && arready == 0) |=> $stable(arregion)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARREGION_STABLE: ARREGION didn't remain stable when ARVALID is asserted and ARREADY is low")

        // Assertion AXI4_ERRM_ARREGION_X
        // A value of X on ARQOS is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARREGION_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (arvalid == 1 |-> !$isunknown(arregion)))
            else
            	`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARREGION_X: ARREGION went to X or Z when ARVALID is HIGH")

        // Assertion AXI4_ERRM_ARUSER_TIEOFF
        // ARUSER must be stable when ARUSER_WIDTH has been set to zero
        assert_AXI4_ERRM_ARUSER_TIEOFF : assert property (
        	disable iff (!has_checks || !sig_reset)
        	(ARUSER_WIDTH == 0 |-> $stable(aruser)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARUSER_TIEOFF: ARUSER not stable when ARUSER_WIDTH set to zero")

        // Assertion AXI4_ERRM_ARID_TIEOFF
        // ARID must be stable when RID_WIDTH has been set to zero
        assert_AXI4_ERRM_ARID_TIEOFF : assert property (
        	disable iff(!has_checks || !sig_reset)
        	(RID_WIDTH == 0 |-> $stable(arid)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRM_ARID_TIEOFF: ARID not stable when RID_WIDTH set to zero")

       	// Assertion AXI4_ERRS_RID_STABLE
        // RID remains stable when RVALID is asserted and RREADY is LOW
        assert_AXI4_ERRS_RID_STABLE : assert property (
        	disable iff(!has_checks || !sig_reset || !rvalid_rready_flag)
        	((rvalid == 1 && rready == 0) |=> $stable(rid)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRS_RID_STABLE: RID didn't remain stable when RVALID is asserted and RREADY is low")

        // Assertion AXI4_ERRS_RID_X
        // A value of X on RID is not permitted when RVALID is HIGH
        assert_AXI4_ERRS_RID_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (rvalid == 1 |-> !$isunknown(rid)))
            else
            	`uvm_error("ASSERTION_ERR", "AXI4_ERRS_RID_X: RID went to X or Z when RVALID is HIGH")

        // AXI4_ERRS_RDATA_STABLE
        // RDATA remains stable when RVALID is asserted and RREADY is LOW
        assert_AXI4_ERRS_RDATA_STABLE : assert property (
        	disable iff(!has_checks || !sig_reset || !rvalid_rready_flag)
        	((rvalid == 1 && rready == 0) |=> $stable(rdata)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRS_RDATA_STABLE: RDATA didn't remain stable when RVALID is asserted and RREADY is low")

        // Assertion AXI4_ERRS_RDATA_X
        // A value of X on RDATA is not permitted when RVALID is HIGH
        assert_AXI4_ERRS_RDATA_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (rvalid == 1 |-> !$isunknown(rdata)))
            else
            	`uvm_error("ASSERTION_ERR", "AXI4_ERRS_RDATA_X: RDATA went to X or Z when RVALID is HIGH")

        // Assertion AXI4_ERRS_RRESP_STABLE
        // RRESP remains stable when RVALID is asserted and RREADY is LOW
        assert_AXI4_ERRS_RRESP_STABLE : assert property (
        	disable iff(!has_checks || !sig_reset || !rvalid_rready_flag)
        	((rvalid == 1 && rready == 0) |=> $stable(rresp)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRS_RRESP_STABLE: RRESP didn't remain stable when RVALID is asserted and RREADY is low")

       	// Assertion AXI4_ERRS_RRESP_X
        // A value of X on RRESP is not permitted when RVALID is HIGH
        assert_AXI4_ERRS_RRESP_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (rvalid == 1 |-> !$isunknown(rresp)))
            else
            	`uvm_error("ASSERTION_ERR", "AXI4_ERRS_RRESP_X: RRESP went to X or Z when RVALID is HIGH")

        // Assertion AXI4_ERRS_RLAST_STABLE
        // RLAST remains stable when RVALID is asserted and RREADY is LOW
        assert_AXI4_ERRS_RLAST_STABLE : assert property (
        	disable iff(!has_checks || !sig_reset || !rvalid_rready_flag)
        	((rvalid == 1 && rready == 0) |=> $stable(rlast)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRS_RLAST_STABLE: RLAST didn't remain stable when RVALID is asserted and RREADY is low")

       	// Assertion AXI4_ERRS_RLAST_X
        // A value of X on RLAST is not permitted when RVALID is HIGH
        assert_AXI4_ERRS_RLAST_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (rvalid == 1 |-> !$isunknown(rlast)))
            else
            	`uvm_error("ASSERTION_ERR", "AXI4_ERRS_RLAST_X: RLAST went to X or Z when RVALID is HIGH")

        // Assertion AXI4_ERRS_RVALID_RESET
        // RVALID is low for the first cycle after ARESETn goes HIGH
        assert_AXI4_ERRS_RVALID_RESET : assert property (
        	disable iff(!has_checks || !sig_reset)
        	(reset_flag == 1 |-> (rvalid == 0)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRS_RVALID_RESET: RVALID not low for the first cycle after ARESETn goes HIGH")

        // Assertion AXI4_ERRS_RVALID_STABLE
        // When RVALID is asserted, then it remains asserted until RREADY is HIGH
       	/*assert_AXI4_ERRS_RVALID_STABLE : assert property (
       		disable iff(!has_checks || !sig_reset)
       		(if (rvalid == 1)
                !rready |-> rvalid))
       		else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRS_RVALID_STABLE: RVALID was asserted, but it didn't remain asserted until RREADY is HIGH")*/

        // Assertion AXI4_ERRS_RVALID_X
        // A value of X on RVALID is not permitted when not in reset
       	assert_AXI4_ERRS_RVALID_X : assert property (
        	disable iff(!has_checks || !sig_reset)
        	(sig_reset == 0 |-> !$isunknown(rvalid)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRS_RVALID_X: RVALID went to X or Z when not in reset")

        // Assertion AXI4_ERRM_RREADY_X
       	// A value of X on RREADY is not permitted when not in reset
       	assert_AXI4_ERRS_RREADY_X : assert property (
        	disable iff(!has_checks || !sig_reset)
        	(sig_reset == 0 |-> !$isunknown(rready)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRS_RREADY_X: RREADY went to X or Z when not in reset")

        // Assertion AXI4_RECM_RREADY_MAX_WAIT
       	// Recommended that RREADY is asserted within MAXWAITS cycles of RVALID being asserted
        assert_AXI4_RECM_RREADY_MAX_WAIT : assert property (
            disable iff(!has_checks || !sig_reset)
            (rvalid |-> ##[0:MAXWAITS]rready))
            else
                `uvm_warning("ASSERTION_WARNING", "AXI4_RECM_RREADY_MAX_WAIT: RREADY is not asserted within MAXWAITS cycles of RVALID being asserted")

       	// Assertion AXI4_ERRS_RUSER_X
       	// A value of X on RUSER is not permitted when RVALID is HIGH
       	assert_AXI4_ERRS_RUSER_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (rvalid == 1 |-> !$isunknown(ruser)))
            else
            	`uvm_error("ASSERTION_ERR", "AXI4_ERRS_RUSER_X: RUSER went to X or Z when RVALID is HIGH")

        // Assertion AXI4_ERRS_RUSER_STABLE
        // RUSER remains stable when RVALID is asserted, and RREADY is LOW
        assert_AXI4_ERRS_RUSER_STABLE : assert property (
        	disable iff(!has_checks || !sig_reset || !rvalid_rready_flag)
        	((rvalid == 1 && rready == 0) |=> $stable(ruser)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRS_RUSER_STABLE: RUSER didn't remain stable when RVALID is asserted and RREADY is low")

        // Assertion AXI4_ERRS_RUSER_TIEOFF
        // RUSER must be stable when RUSER_WIDTH has been set to zero
        assert_AXI4_ERRS_RUSER_TIEOFF : assert property (
        	disable iff (!has_checks || !sig_reset)
        	(RUSER_WIDTH == 0 |-> $stable(ruser)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRS_RUSER_TIEOFF: RUSER not stable when RUSER_WIDTH set to zero")

        // Assertion AXI4_ERRS_RID_TIEOFF
        // RID must be stable when RID_WIDTH has been set to zero
        assert_AXI4_ERRS_RID_TIEOFF : assert property (
        	disable iff(!has_checks || !sig_reset)
        	(RID_WIDTH == 0 |-> $stable(rid)))
        	else
        		`uvm_error("ASSERTION_ERR", "AXI4_ERRS_RID_TIEOFF: RID not stable when RID_WIDTH set to zero")


        // set arvalid_arready_flag if needed
        // must come after all assertions
        // the first time arvalid goes high and arready is low, the assertions that
        // id, len, addr... stay stable should not be checked
        if((arvalid == 1) && (arready == 0))
            arvalid_arready_flag = 1;
        else
            arvalid_arready_flag = 0;

        // set rvalid_rready_flag if needed
        if((rvalid == 1) && (rready == 0))
            rvalid_rready_flag = 1;
        else
            rvalid_rready_flag = 0;
	end

endinterface : axi_if

`endif
