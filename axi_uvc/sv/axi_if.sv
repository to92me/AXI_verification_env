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

  parameter ADDR_WIDTH = 64;	// Width of the address bus
  parameter DATA_WIDTH = 16;	// Width of the system data buses
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
  logic      					arlock;
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


  //aditional signals for checks - do another way // TODO

  bit awready_awvlaid_true 		= 0;
  bit wready_wvalid_true 		= 0;
  bit bready_bvalid_true 		= 0;

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



 // ======================================================= WRITE ASSERTIONS =======================================================

//============================= TABLE OF CONTENT ===++
//  1. addr_write width
//	2. wid stable if transfer is not completed
//	3. awid stable if transfer is not completed
// 	4. bid stable if transfer is not completed
//  5. wid must be setted when wready is high
// 	6. awid must be setted when awready is high
//	7. bid must be setted when bready is high
// 	8. awaddr must be stable if awvalid is high
//	9. awaddr must be setted if awvalid is high
// 10.


//1. ADDR_WRITE======================================================================
        // Write Address Channel Transaction
    //Address (12-64)
        assertion_ADDR_WIDTH : assert property(
           (ADDR_WIDTH >= 12 &&  ADDR_WIDTH <= 64 ))
        else
           `uvm_error("ASSERTION_ERR","ADDR_WIDTH: should be inside 12 : 64");




//2. WID_STABLE =======================================================================
        //WID remains stable when WVALID is asserted and WREADY is low
        //this means that ID can not change if transfer is not completed
        assert_AXI4_ERRM_WID_STABLE : assert property (
	        disable iff(!has_checks || !sig_reset || !wready_wvalid_true)
	        ((wvalid == 1 && wready == 0) |=> $stable(wid)))
        else
	        `uvm_error("ASSERTION_ERR","AXI4_ERRM_WID_STABLE: WID didn't remain stable when WVALID is asserted and WREADY is low")




//3. AWID_STABLE =======================================================================:
         //WID remains stable when WVALID is asserted and WREADY is low
         //this means that ID can not change if transfer is not completed
	    assert_AXI4_ERRM_AWID_STABLE : assert property (
		    disable iff(!has_checks || !sig_reset || !awready_awvlaid_true)
      		((awvalid == 1 && awready == 0) |=> $stable(awid)))
      	else
	      	`uvm_error("ASSERTION_ERR","AXI4_ERRM_AWID_STABLE: AWID didn't remain stable when AWVALID is asserted and AWREADY is low")





//4. BID_STABLE =======================================================================:
        //WID remains stable when BVALID is asserted and BREADY is low
        //this means that ID can not change if transfer is not completed
	      	assert_AXI4_ERRM_BID_STABLE : assert property (
		      disable iff(!has_checks || !sig_reset || !bready_bvalid_true)
		      ((bvalid == 1 && bready == 0) |=> $stable(bid)))
	      else
		      `uvm_error("ASSERTION_ERR","AXI4_ERRM_AWID_STABLE: BID didn't remain stable when BVALID is asserted and BREADY is low")





//5. WID_SETTED ========================================================================
        // A value of X on WID is not permitted when WVALID is HIGH
		 assert_AXI4_ERRM_WID_X : assert property (
			 disable iff(!has_checks || !sig_reset)
			 (wvalid == 1 |-> !$isunknown(wid)))
		 else
			 `uvm_error("ASSERTION_ERR", "assert_AXI4_ERRM_WID_X: A value of X on WID is not permitted when WVALID is HIGH")





//6. AWID_SETTED ========================================================================
        // A value of X on AWID is not permitted when AWVALID is HIGH
		assert_AXI4_ERRM_AWID_X : assert property (
			disable iff(!has_checks || !sig_reset)
			(awvalid == 1 |-> !$isunknown(awid)))
		else
			`uvm_error("ASSERTION_ERR", "assert_AXI4_ERRM_AWID_X: A value of X on AWID is not permitted when AWVALID is HIGH")





//7. AWID_SETTED ========================================================================
        // A value of X on AWID is not permitted when AWVALID is HIGH
		assert_AXI4_ERRM_BID_X : assert property (
			disable iff(!has_checks || !sig_reset)
			(bvalid == 1 |-> !$isunknown(bid)))
		else
			`uvm_error("ASSERTION_ERR", "assert_AXI4_ERRM_BID_X: A value of X on BID is not permitted when BVALID is HIGH")





//8. AWADDR_STABLE========================================================================
        // WADDR remains stable when WVALID is asserted and WREADY is low
        assert_AXI4_ERRM_AWADDR_STABLE : assert property (
          disable iff(!has_checks || !sig_reset || !awready_awvlaid_true)
          ((awvalid == 1 && awready == 0) |=> $stable(awaddr)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_WADDR_STABLE: AWADDR didn't remain stable when AWVALID is asserted and AWREADY is low")




//9. AWADDR_SETTED========================================================================
        // Assertion AXI4_ERRM_AWADDR_X
        // A value of X on AWADDR is not permitted when AWVALID is HIGH
        assert_AXI4_ERRM_AWADDR_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (awvalid == 1 |-> !$isunknown(awaddr)))
            else
              `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWADDR_X: AWADDR went to X or Z when AWVALID is HIGH")




//10. AWLEN_STABLE==========================================================================
        // AWLEN remains stable when AWVALID is asserted and AWREADY is LOW
        assert_AXI4_ERRM_AWLEN_STABLE : assert property (
          disable iff(!has_checks || !sig_reset || !awready_awvlaid_true)
          ((awvalid == 1 && awready == 0) |=> $stable(awlen)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWLEN_STABLE: AWLEN didn't remain stable when AWVALID is asserted and AWREADY is low")




//11. AWLEN_STABLE==========================================================================
        // A value of X on ARLEN is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_AWLEN_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (awvalid == 1 |-> !$isunknown(awlen)))
            else
              `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWLEN_X: AWLEN went to X or Z when AWVALID is HIGH")




//12. AWSIZE_STABLE =========================================================================
        // AWSIZE remains stable when AWVALID is asserted and AWREADY is LOW
        assert_AXI4_ERRM_AWSIZE_STABLE : assert property (
          disable iff(!has_checks || !sig_reset || !awready_awvlaid_true)
          ((awvalid == 1 && awready == 0) |=> $stable(awsize)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWSIZE_STABLE: AWSIZE didn't remain stable when AWVALID is asserted and AWREADY is low")




//13. AWSIZE_SETTED ==========================================================================
        // A value of X on AWSIZE is not permitted when AWVALID is HIGH
        assert_AXI4_ERRM_AWSIZE_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (awvalid == 1 |-> !$isunknown(awsize)))
            else
              `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWSIZE_X: AWSIZE went to X or Z when AWVALID is HIGH")




//14. AWBURST_STABLE===========================================================================
        // ARBURST remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_AWBURST_STABLE : assert property (
          disable iff(!has_checks || !sig_reset || !awready_awvlaid_true)
          ((awvalid == 1 && awready == 0) |=> $stable(awburst)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWBURST_STABLE: AWBURST didn't remain stable when AWVALID is asserted and AWREADY is low")



//15. AWBURST_SETTED===========================================================================
        // A value of X on AWBURST is not permitted when AWVALID is HIGH
        assert_AXI4_ERRM_AWBURST_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (awvalid == 1 |-> !$isunknown(awburst)))
            else
              `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWBURST_X: AWBURST went to X or Z when AWVALID is HIGH")




//16. AWLOCK_STABLE===========================================================================
        // AWLOCK remains stable when AWVALID is asserted and AWREADY is LOW
        assert_AXI4_ERRM_AWLOCK_STABLE : assert property (
          disable iff(!has_checks || !sig_reset || !awready_awvlaid_true)
          ((awvalid == 1 && awready == 0) |=> $stable(awlock)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWLOCK_STABLE: AWLOCK didn't remain stable when AWVALID is asserted and AWREADY is low")




//17. AWLOCK_SETTED===========================================================================
        // A value of X on AWLOCK is not permitted when AWVALID is HIGH
        assert_AXI4_ERRM_AWLOCK_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (awvalid == 1 |-> !$isunknown(awlock)))
            else
              `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWLOCK_X: AWLOCK went to X or Z when AWVALID is HIGH")




//18. AWCACHE_STABLE==========================================================================
        // ARCACHE remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_AWCACHE_STABLE : assert property (
          disable iff(!has_checks || !sig_reset || !awready_awvlaid_true)
          ((awvalid == 1 && awready == 0) |=> $stable(awcache)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWCACHE_STABLE: AWCACHE didn't remain stable when AWVALID is asserted and AWREADY is low")




//19. AWCACHE_SETTED==========================================================================
        // A value of X on AWCACHE is not permitted when AWVALID is HIGH
        assert_AXI4_ERRM_AWCACHE_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (awvalid == 1 |-> !$isunknown(awcache)))
            else
              `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWCACHE_X: AWCACHE went to X or Z when AWVALID is HIGH")




//20. AWPROT_STABLE==========================================================================
        // ARPROT remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_AWPROT_STABLE : assert property (
          disable iff(!has_checks || !sig_reset || !awready_awvlaid_true)
          ((awvalid == 1 && awready == 0) |=> $stable(awprot)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWPROT_STABLE: AWPROT didn't remain stable when AWVALID is asserted and AWREADY is low")




//21. AWPROT_SETTED==========================================================================
        // A value of X on AWPROT is not permitted when AWVALID is HIGH
        assert_AXI4_ERRM_AWPROT_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (awvalid == 1 |-> !$isunknown(awprot)))
            else
              `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWPROT_X: AWPROT went to X or Z when AWVALID is HIGH")




//22. AWVALID_LOW_AFTER_RESET================================================================
        // AWVALID is low for the first cycle after ARESETn goes HIGH
        assert_AXI4_ERRM_AWVALID_RESET : assert property (
          disable iff(!has_checks || !sig_reset)
          (reset_flag == 1 |-> (awvalid == 0)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWVALID_RESET: AWVALID not low for the first cycle after ARESETn goes HIGH")




//23. WVALID_LOW_AFTER_RESET=================================================================
          assert_AXI4_ERRM_WVALID_RESET : assert property (
          disable iff(!has_checks || !sig_reset)
          (reset_flag == 1 |-> (wvalid == 0)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_WVALID_RESET: WVALID not low for the first cycle after ARESETn goes HIGH")




//23. BVALID_LOW_AFTER_RESET=================================================================
//          assert_AXI4_ERRM_BVALID_RESET : assert property (
//          disable iff(!has_checks || !sig_reset)
//          (reset_flag == 1 |-> (bvalid == 0)))
//          else
//            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_BVALID_RESET: BVALID not low for the first cycle after ARESETn goes HIGH")



//24. AWVALID_HIGH===========================================================================
        // When AWVALID is asserted, then it remains asserted until AWREADY is HIGH
         assert_AXI4_ERRM_AWVALID_STABLE : assert property (
           disable iff(!has_checks || !sig_reset)
           (if (awvalid == 1)
                !awready |-> awvalid))
           else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWVALID_STABLE: AWVALID was asserted, but it didn't remain asserted until AWREADY is HIGH")




//25. WVALID_HIGH=============================================================================
		// When WVALID is asserted, then it remains asserted until WREADY is HIGH
         assert_AXI4_ERRM_WVALID_STABLE : assert property (
           disable iff(!has_checks || !sig_reset)
           (if (wvalid == 1)
                !wready |-> wvalid))
           else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_WVALID_STABLE: WVALID was asserted, but it didn't remain asserted until WREADY is HIGH")




//26. BVALID_HIGH=============================================================================
       	// When BVALID is asserted, then it remains asserted until BREADY is HIGH
         assert_AXI4_ERRM_BVALID_STABLE : assert property (
           disable iff(!has_checks || !sig_reset)
           (if (bvalid == 1)
                !bready |-> bvalid))
           else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_BVALID_STABLE: BVALID was asserted, but it didn't remain asserted until BREADY is HIGH")




//27. AWVALID_SETTED ==========================================================================
        // A value of X on AWVALID is not permitted when not in reset
         assert_AXI4_ERRM_AWVALID_X : assert property (
          disable iff(!has_checks || !sig_reset)
          (sig_reset == 0 |-> !$isunknown(awvalid)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWVALID_X: AWVALID went to X or Z when not in reset")




//28. WVALID_SETTED ===========================================================================
            // A value of X on AWVALID is not permitted when not in reset
         assert_AXI4_ERRM_WVALID_X : assert property (
          disable iff(!has_checks || !sig_reset)
          (sig_reset == 0 |-> !$isunknown(wvalid)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_WVALID_X: WVALID went to X or Z when not in reset")



//29. WVALID_SETTED ===========================================================================
            // A value of X on AWVALID is not permitted when not in reset
         assert_AXI4_ERRM_BVALID_X : assert property (
          disable iff(!has_checks || !sig_reset)
          (sig_reset == 0 |-> !$isunknown(bvalid)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_BVALID_X: BVALID went to X or Z when not in reset")



//30. AWREADY_SETTED ===========================================================================
         // A value of X on AWREADY is not permitted when not in reset
         assert_AXI4_ERRM_AWREADY_X : assert property (
          disable iff(!has_checks || !sig_reset)
          (sig_reset == 0 |-> !$isunknown(awready)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWREADY_X: AWREADY went to X or Z when not in reset")




//31. WREADY_SETTED ===========================================================================
         // A value of X on WREADY is not permitted when not in reset
         assert_AXI4_ERRM_WREADY_X : assert property (
          disable iff(!has_checks || !sig_reset)
          (sig_reset == 0 |-> !$isunknown(wready)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_WREADY_X: WREADY went to X or Z when not in reset")




//32. BWREADY_SETTED ===========================================================================
         // A value of X on BREADY is not permitted when not in reset
         assert_AXI4_ERRM_BREADY_X : assert property (
          disable iff(!has_checks || !sig_reset)
          (sig_reset == 0 |-> !$isunknown(bready)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_BREADY_X: BREADY went to X or Z when not in reset")




////33.
//
//        // Assertion AXI4_RECS_ARREADY_MAX_WAIT
//         // Recommended that ARREADY is asserted within MAXWAITS cycles of ARVALID being asserted
//        assert_AXI4_RECS_ARREADY_MAX_WAIT : assert property (
//            disable iff(!has_checks || !sig_reset)
//            (arvalid |-> ##[0:MAXWAITS]arready))
//            else
//                `uvm_warning("ASSERTION_WARNING", "AXI4_RECS_ARREADY_MAX_WAIT: ARREADY is not asserted within MAXWAITS cycles of ARVALID being asserted")




//34. AWUSER_STABLE ===========================================================================
        // ARUSER remains stable when AWVALID is asserted, and AWREADY is LOW
        assert_AXI4_ERRM_AWUSER_STABLE : assert property (
          disable iff(!has_checks || !sig_reset || !awready_awvlaid_true)
          ((awvalid == 1 && awready == 0) |=> $stable(awuser)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWUSER_STABLE: AWUSER didn't remain stable when AWVALID is asserted and AWREADY is low")




//35. WUSER_STABLE ===========================================================================
        // ARUSER remains stable when WVALID is asserted, and WREADY is LOW
        assert_AXI4_ERRM_WUSER_STABLE : assert property (
          disable iff(!has_checks || !sig_reset || !wready_wvalid_true)
          ((wvalid == 1 && wready == 0) |=> $stable(wuser)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_WUSER_STABLE: WUSER didn't remain stable when WVALID is asserted and WREADY is low")




//36. AWUSER_SETTED  ===========================================================================
        // A value of X on ARUSER is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_AWUSER_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (awvalid == 1 |-> !$isunknown(awuser)))
            else
              `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWUSER_X: AWUSER went to X or Z when AWVALID is HIGH")




//37. WUSER_SETTED  ===========================================================================
        // A value of X on ARUSER is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_WUSER_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (wvalid == 1 |-> !$isunknown(wuser)))
            else
              `uvm_error("ASSERTION_ERR", "AXI4_ERRM_WUSER_X: WUSER went to X or Z when WVALID is HIGH")





//38. AWQOS_STABLE  ===========================================================================
        // AWQOS remains stable when AWVALID is asserted and AWREADY is LOW
        assert_AXI4_ERRM_AWQOS_STABLE : assert property (
          disable iff(!has_checks || !sig_reset || !awready_awvlaid_true)
          ((awvalid == 1 && awready == 0) |=> $stable(awqos)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWQOS_STABLE: AWQOS didn't remain stable when AWVALID is asserted and AWREADY is low")





//39. AWQOS_SETTED ===========================================================================
        // A value of X on AWQOS is not permitted when AWVALID is HIGH
        assert_AXI4_ERRM_AWQOS_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (awvalid == 1 |-> !$isunknown(awqos)))
            else
              `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWQOS_X: AWQOS went to X or Z when AWVALID is HIGH")




//40. AWREGION_STABLE ===========================================================================
        // ARREGION remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_AWREGION_STABLE : assert property (
          disable iff(!has_checks || !sig_reset || !awready_awvlaid_true)
          ((awvalid == 1 && awready == 0) |=> $stable(awregion)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWREGION_STABLE: AWREGION didn't remain stable when AWVALID is asserted and AWREADY is low")




//41. AWREGION_SETTED ===========================================================================
        // Assertion AXI4_ERRM_ARREGION_X
        // A value of X on ARQOS is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_AWREGION_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (awvalid == 1 |-> !$isunknown(awregion)))
            else
              `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWREGION_X: AWREGION went to X or Z when AWVALID is HIGH")



//42. AWUSER_TIEOFF ===========================================================================
        // AWUSER must be stable when AWUSER_WIDTH has been set to zero
        assert_AXI4_ERRM_AWUSER_TIEOFF : assert property (
          disable iff (!has_checks || !sig_reset)
          (AWUSER_WIDTH == 0 |-> $stable(awuser)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWUSER_TIEOFF: AWUSER not stable when AWUSER_WIDTH set to zero")



//43. WUSER_TIEOFF ===========================================================================
        // AWUSER must be stable when AWUSER_WIDTH has been set to zero
        assert_AXI4_ERRM_WUSER_TIEOFF : assert property (
          disable iff (!has_checks || !sig_reset)
          (WUSER_WIDTH == 0 |-> $stable(wuser)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_WUSER_TIEOFF: WUSER not stable when WUSER_WIDTH set to zero")




//44.AWID_TIEOFF ==============================================================================
        // AWID must be stable when WID_WIDTH has been set to zero
        assert_AXI4_ERRM_AWID_TIEOFF : assert property (
          disable iff(!has_checks || !sig_reset)
          (WID_WIDTH == 0 |-> $stable(awid)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_AWID_TIEOFF: AWID not stable when WID_WIDTH set to zero")


//45.WID_TIEOFF ==============================================================================
        // WID must be stable when WID_WIDTH has been set to zero
        assert_AXI4_ERRM_WID_TIEOFF : assert property (
          disable iff(!has_checks || !sig_reset)
          (WID_WIDTH == 0 |-> $stable(wid)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_WID_TIEOFF: WID not stable when WID_WIDTH set to zero")




//46.BID_TIEOFF ==============================================================================
        // BID must be stable when WID_WIDTH has been set to zero
        assert_AXI4_ERRM_BID_TIEOFF : assert property (
          disable iff(!has_checks || !sig_reset)
          (WID_WIDTH == 0 |-> $stable(bid)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRM_BID_TIEOFF: BID not stable when WID_WIDTH set to zero")






//47. WDATA_STABLE==============================================================================
        // RDATA remains stable when RVALID is asserted and RREADY is LOW
        assert_AXI4_ERRS_WDATA_STABLE : assert property (
          disable iff(!has_checks || !sig_reset || !wready_wvalid_true)
          ((wvalid == 1 && wready == 0) |=> $stable(rdata)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRS_WDATA_STABLE: WDATA didn't remain stable when WVALID is asserted and WREADY is low")



//48. WDATA_SETTED==============================================================================
        // A value of X on WDATA is not permitted when WVALID is HIGH
        assert_AXI4_ERRS_WDATA_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (wvalid == 1 |-> !$isunknown(wdata)))
            else
              `uvm_error("ASSERTION_ERR", "AXI4_ERRS_WDATA_X: WDATA went to X or Z when WVALID is HIGH")




//49. BRESP_STABLE==============================================================================
        // BRESP remains stable when BVALID is asserted and BREADY is LOW
        assert_AXI4_ERRS_BRESP_STABLE : assert property (
          disable iff(!has_checks || !sig_reset || !bready_bvalid_true)
          ((bvalid == 1 && bready == 0) |=> $stable(bresp)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRS_BRESP_STABLE: BRESP didn't remain stable when BVALID is asserted and BREADY is low")




//50. BRESP_SETTED==============================================================================
        // A value of X on BRESP is not permitted when BVALID is HIGH
        assert_AXI4_ERRS_BRESP_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (bvalid == 1 |-> !$isunknown(bresp)))
            else
              `uvm_error("ASSERTION_ERR", "AXI4_ERRS_BRESP_X: BRESP went to X or Z when BVALID is HIGH")




//51. WLAST_STABLE ==============================================================================
        // RLAST remains stable when RVALID is asserted and RREADY is LOW
        assert_AXI4_ERRS_WLAST_STABLE : assert property (
          disable iff(!has_checks || !sig_reset || !wready_wvalid_true)
          ((wvalid == 1 && wready == 0) |=> $stable(wlast)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRS_RLAST_STABLE: RLAST didn't remain stable when RVALID is asserted and RREADY is low")



//52. WLAST_SETTED ==============================================================================
        // A value of X on RLAST is not permitted when RVALID is HIGH
        assert_AXI4_ERRS_WLAST_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (wvalid == 1 |-> !$isunknown(wlast)))
            else
              `uvm_error("ASSERTION_ERR", "AXI4_ERRS_WLAST_X: WLAST went to X or Z when WVALID is HIGH")



////53 .WLAST_LOW_AFTER_RESET ======================================================================
//        // RVALID is low for the first cycle after ARESETn goes HIGH
//        assert_AXI4_ERRS_RVALID_RESET : assert property (
//          disable iff(!has_checks || !sig_reset)
//          (reset_flag == 1 |-> (rvalid == 0)))
//          else
//            `uvm_error("ASSERTION_ERR", "AXI4_ERRS_RVALID_RESET: RVALID not low for the first cycle after ARESETn goes HIGH")

//54.        // Assertion AXI4_ERRS_RVALID_STABLE
        // When RVALID is asserted, then it remains asserted until RREADY is HIGH
         /*assert_AXI4_ERRS_RVALID_STABLE : assert property (
           disable iff(!has_checks || !sig_reset)
           (if (rvalid == 1)
                !rready |-> rvalid))
           else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRS_RVALID_STABLE: RVALID was asserted, but it didn't remain asserted until RREADY is HIGH")*/


// 55. AWVALID_SETTED ======================================================================
        // A value of X on AWVALID is not permitted when not in reset
         assert_AXI4_ERRS_AWVALID_X : assert property (
          disable iff(!has_checks || !sig_reset)
          (sig_reset == 0 |-> !$isunknown(awvalid)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRS_AWVALID_X: AWVALID went to X or Z when not in reset")




//56. WVALID_SETTED ======================================================================
       // A value of X on RVALID is not permitted when not in reset
         assert_AXI4_ERRS_WVALID_X : assert property (
          disable iff(!has_checks || !sig_reset)
          (sig_reset == 0 |-> !$isunknown(wvalid)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRS_WVALID_X: WVALID went to X or Z when not in reset")




//57. BVALID_SETTED =======================================================================
      // A value of X on RVALID is not permitted when not in reset
         assert_AXI4_ERRS_BVALID_X : assert property (
          disable iff(!has_checks || !sig_reset)
          (sig_reset == 0 |-> !$isunknown(bvalid)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRS_BVALID_X: BVALID went to X or Z when not in reset")




//58.
//        // Assertion AXI4_RECM_RREADY_MAX_WAIT
//         // Recommended that RREADY is asserted within MAXWAITS cycles of RVALID being asserted
//        assert_AXI4_RECM_RREADY_MAX_WAIT : assert property (
//            disable iff(!has_checks || !sig_reset)
//            (rvalid |-> ##[0:MAXWAITS]rready))
//            else
//                `uvm_warning("ASSERTION_WARNING", "AXI4_RECM_RREADY_MAX_WAIT: RREADY is not asserted within MAXWAITS cycles of RVALID being asserted")


//59. BUSER_SETTED ================================================================
         // A value of X on RUSER is not permitted when RVALID is HIGH
         assert_AXI4_ERRS_BUSER_X : assert property (
            disable iff(!has_checks || !sig_reset)
            (bvalid == 1 |-> !$isunknown(buser)))
            else
              `uvm_error("ASSERTION_ERR", "AXI4_ERRS_BUSER_X: BUSER went to X or Z when BVALID is HIGH")



//60.AWUSER ================================================================
        // AWUSER remains stable when AWVALID is asserted, and AWREADY is LOW
        assert_AXI4_ERRS_AWUSER_STABLE : assert property (
          disable iff(!has_checks || !sig_reset || !awready_awvlaid_true)
          ((awvalid == 1 && awready == 0) |=> $stable(awuser)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRS_AWUSER_STABLE: AWUSER didn't remain stable when AWVALID is asserted and AWREADY is low")





//61.WUSER ================================================================
        // WUSER remains stable when WVALID is asserted, and WREADY is LOW
        assert_AXI4_ERRS_WUSER_STABLE : assert property (
          disable iff(!has_checks || !sig_reset || !wready_wvalid_true)
          ((wvalid == 1 && wready == 0) |=> $stable(wuser)))
          else
            `uvm_error("ASSERTION_ERR", "AXI4_ERRS_WUSER_STABLE: WUSER didn't remain stable when WVALID is asserted and WREADY is low")



// ADITIONAL FLAGS

        if((wvalid == 1) && (wready == 0))
            wready_wvalid_true = 1;
        else
            wready_wvalid_true = 0;


        if((awvalid == 1) && (awready == 0))
	        awready_awvlaid_true = 1;
        else
	        awready_awvlaid_true = 0;



        if((bvalid == 1) && (bready == 0))
            bready_bvalid_true = 1;
        else
            bready_bvalid_true = 0;

  end





endinterface : axi_if

`endif
