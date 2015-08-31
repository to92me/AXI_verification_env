`ifndef AXI_IF
`define AXI_IF

//-------------------------------------------------------------------------
//
// INTERFACE: axi_if
//
//-------------------------------------------------------------------------

interface axi_if (input sig_reset, input sig_clock);

	parameter ADDR_WIDTH = 32;
	parameter DATA_WIDTH = 64;
	parameter ID_WIDTH = 32;
	
	parameter STRB_WIDTH = DATA_WIDTH / 8;

	// write address channel signals
	logic [ID_WIDTH - 1 : 0]	awid;
	logic [ADDR_WIDTH-1 : 0]	awaddr;
	logic [7:0]					awlen;
	logic [2:0]					awsize;
	logic [1:0]					awburst;
	logic [1:0]					awlock;
	logic [3:0]					awcache;
	logic [2:0] 				awprot;
	logic [3:0]					awqos;
	logic [3:0]					awregion;
	// awuser
    logic 						awvalid;
	logic 						awready;

	// write data channel signals
	logic [ID_WIDTH-1 : 0]		wid;
	logic [DATA_WIDTH-1 : 0]	wdata;
	logic [STRB_WIDTH-1 : 0]	wstrb;
	logic						wlast;
	// wuser
	logic						wvalid;
	logic						wready;

	// write response channel signals
	logic [ID_WIDTH-1 : 0]		bid;
	logic [1:0]					bresp;
	// buser
	logic						bready;
	logic						bvalid;

	// read address channel signals
	logic [ID_WIDTH-1 : 0]		arid;
	logic [ADDR_WIDTH-1 : 0]	araddr;
	logic [7:0]					arlen;
	logic [2:0]					arsize;
	logic [1:0]					arburst;
	logic [1:0]					arlock;
	logic [3:0]					arcache;
	logic [2:0]					arprot;
	logic [3:0]					arqos;
	logic [3:0]					arregion;
	// aruser
	logic						arvalid;
	logic						arready;

	// read data channel signals
	logic [ID_WIDTH-1 : 0]		rid;
	logic [DATA_WIDTH-1 : 0]	rdata;
	logic [1:0]					rresp;
	logic						rlast;
	// ruser
	logic						rvalid;
	logic						rready;


	// Control flags
	bit							has_checks = 1;
	bit							has_coverage = 1;

	// vif assertions
	always @(posedge sig_clock)
	begin
		// ARID remains stable when ARVALID is asserted and ARREADY is low
		assert_AXI4_ERRM_ARID_STABLE : assert property (
			disable iff(!has_checks) 
			((arvalid == 1 && arready == 0) |=> $stable(arid)))
            else
            	$error("AXI4_ERRM_ARID_STABLE\n ARID didn't remain stable when ARVALID is asserted and ARREADY is low");

        // A value of X on ARID is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARID_X : assert property (
        	disable iff(!has_checks)
        	(arvalid == 1 |-> !$isunknown(arid)))
        	else
        		$error("AXI4_ERRM_ARID_X\n A value of X on ARID is not permitted when ARVALID is HIGH");

        // 4kb boundary ???

        // ARADDR remains stable when ARVALID is asserted and ARREADY is low
        assert_AXI4_ERRM_ARADDR_STABLE : assert property (
        	disable iff(!has_checks)
        	((arvalid == 1 && arready == 0) |=> $stable(araddr)))
        	else
        		$error("AXI4_ERRM_ARADDR_STABLE\n ARADDR didn't remain stable when ARVALID is asserted and ARREADY is low");

        // A value of X on ARADDR is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARADDR_X : assert property (
            disable iff(!has_checks) 
            (arvalid == 1 |-> !$isunknown(araddr)))
            else
            	$error("AXI4_ERRM_ARADDR_X\n ARADDR went to X or Z when ARVALID is HIGH");

        // ARLEN remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_ARLEN_STABLE : assert property (
        	disable iff(!has_checks)
        	((arvalid == 1 && arready == 0) |=> $stable(arlen)))
        	else
        		$error("AXI4_ERRM_ARLEN_STABLE\n ARLEN didn't remain stable when ARVALID is asserted and ARREADY is low");

        // A value of X on ARLEN is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARLEN_X : assert property (
            disable iff(!has_checks) 
            (arvalid == 1 |-> !$isunknown(arlen)))
            else
            	$error("AXI4_ERRM_ARLEN_X\n ARLEN went to X or Z when ARVALID is HIGH");

        // ARSIZE remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_ARSIZE_STABLE : assert property (
        	disable iff(!has_checks)
        	((arvalid == 1 && arready == 0) |=> $stable(arsize)))
        	else
        		$error("AXI4_ERRM_ARSIZE_STABLE\n ARSIZE didn't remain stable when ARVALID is asserted and ARREADY is low");

        // A value of X on ARSIZE is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARSIZE_X : assert property (
            disable iff(!has_checks) 
            (arvalid == 1 |-> !$isunknown(arsize)))
            else
            	$error("AXI4_ERRM_ARSIZE_X\n ARSIZE went to X or Z when ARVALID is HIGH");

        // ARBURST remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_ARBURST_STABLE : assert property (
        	disable iff(!has_checks)
        	((arvalid == 1 && arready == 0) |=> $stable(arburst)))
        	else
        		$error("AXI4_ERRM_ARBURST_STABLE\n ARBURST didn't remain stable when ARVALID is asserted and ARREADY is low");

        // A value of X on ARBURST is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARBURST_X : assert property (
            disable iff(!has_checks) 
            (arvalid == 1 |-> !$isunknown(arburst)))
            else
            	$error("AXI4_ERRM_ARBURST_X\n ARBURST went to X or Z when ARVALID is HIGH");

        // ARLOCK remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_ARLOCK_STABLE : assert property (
        	disable iff(!has_checks)
        	((arvalid == 1 && arready == 0) |=> $stable(arlock)))
        	else
        		$error("AXI4_ERRM_ARLOCK_STABLE\n ARLOCK didn't remain stable when ARVALID is asserted and ARREADY is low");

        // A value of X on ARLOCK is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARLOCK_X : assert property (
            disable iff(!has_checks) 
            (arvalid == 1 |-> !$isunknown(arlock)))
            else
            	$error("AXI4_ERRM_ARLOCK_X\n ARLOCK went to X or Z when ARVALID is HIGH");

        // ARCACHE remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_ARCACHE_STABLE : assert property (
        	disable iff(!has_checks)
        	((arvalid == 1 && arready == 0) |=> $stable(arcache)))
        	else
        		$error("AXI4_ERRM_ARCACHE_STABLE\n ARCACHE didn't remain stable when ARVALID is asserted and ARREADY is low");

        // A value of X on ARCACHE is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARCACHE_X : assert property (
            disable iff(!has_checks) 
            (arvalid == 1 |-> !$isunknown(arcache)))
            else
            	$error("AXI4_ERRM_ARCACHE_X\n ARCACHE went to X or Z when ARVALID is HIGH");

        // ARPROT remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_ARPROT_STABLE : assert property (
        	disable iff(!has_checks)
        	((arvalid == 1 && arready == 0) |=> $stable(arprot)))
        	else
        		$error("AXI4_ERRM_ARPROT_STABLE\n ARPROT didn't remain stable when ARVALID is asserted and ARREADY is low");

        // A value of X on ARPROT is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARPROT_X : assert property (
            disable iff(!has_checks) 
            (arvalid == 1 |-> !$isunknown(arprot)))
            else
            	$error("AXI4_ERRM_ARPROT_X\n ARPROT went to X or Z when ARVALID is HIGH");

        // ARVALID is low for the first cycle after ARESETn goes HIGH
        /*assert_AXI4_ERRM_ARVALID_RESET : assert property (
        	disable iff(!has_checks)
        	(@(negedge sig_reset) |=> (arvalid == 0)))
        	else
        		$error("AXI4_ERRM_ARVALID_RESET\n ARVALID not low for the first cycle after ARESETn goes HIGH");*/

        // When ARVALID is asserted, then it remains asserted until ARREADY is HIGH
       	/*assert_AXI4_ERRM_ARVALID_STABLE : assert property (
       		disable iff(!has_checks)
       		)
       		else
        		$error("AXI4_ERRM_ARVALID_STABLE\n ARVALID was asserted, but it didn't remain asserted until ARREADY is HIGH")*/

        // A value of X on ARVALID is not permitted when not in reset S
       	assert_AXI4_ERRM_ARVALID_X : assert property (
        	disable iff(!has_checks)
        	(sig_reset == 0 |-> !$isunknown(arvalid)))
        	else
        		$error("AXI4_ERRM_ARVALID_X\n ARVALID went to X or Z when not in reset");

       	// A value of X on ARREADY is not permitted when not in reset S
       	assert_AXI4_ERRM_ARREADY_X : assert property (
        	disable iff(!has_checks)
        	(sig_reset == 0 |-> !$isunknown(arready)))
        	else
        		$error("AXI4_ERRM_ARREADY_X\n ARREADY went to X or Z when not in reset");

       // Recommended that ARREADY is asserted within MAXWAITS cycles of ARVALID being asserted
       // A value of X on ARUSER is not permitted when ARVALID is HIGH

        // ARQOS remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_ARQOS_STABLE : assert property (
        	disable iff(!has_checks)
        	((arvalid == 1 && arready == 0) |=> $stable(arqos)))
        	else
        		$error("AXI4_ERRM_ARQOS_STABLE\n ARQOS didn't remain stable when ARVALID is asserted and ARREADY is low");

        // A value of X on ARQOS is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARQOS_X : assert property (
            disable iff(!has_checks) 
            (arvalid == 1 |-> !$isunknown(arqos)))
            else
            	$error("AXI4_ERRM_ARQOS_X\n ARQOS went to X or Z when ARVALID is HIGH");

        // ARREGION remains stable when ARVALID is asserted and ARREADY is LOW
        assert_AXI4_ERRM_ARREGION_STABLE : assert property (
        	disable iff(!has_checks)
        	((arvalid == 1 && arready == 0) |=> $stable(arregion)))
        	else
        		$error("AXI4_ERRM_ARREGION_STABLE\n ARREGION didn't remain stable when ARVALID is asserted and ARREADY is low");

        // A value of X on ARQOS is not permitted when ARVALID is HIGH
        assert_AXI4_ERRM_ARREGION_X : assert property (
            disable iff(!has_checks) 
            (arvalid == 1 |-> !$isunknown(arregion)))
            else
            	$error("AXI4_ERRM_ARREGION_X\n ARREGION went to X or Z when ARVALID is HIGH");

        // ARUSER must be stable when ARUSER_WIDTH has been set to zero

        // ARID must be stable when ID_WIDTH has been set to zero
        assert_AXI4_ERRM_ARID_TIEOFF : assert property (
        	disable iff(!has_checks)
        	(ID_WIDTH == 0 |-> $stable(arid)))
        	else
        		$error("AXI4_ERRM_ARID_TIEOFF\n ARID not stable when ID_WIDTH set to zero");

        // RID remains stable when RVALID is asserted and RREADY is LOW
        assert_AXI4_ERRS_RID_STABLE : assert property (
        	disable iff(!has_checks)
        	((rvalid == 1 && rready == 0) |=> $stable(rid)))
        	else
        		$error("AXI4_ERRS_RID_STABLE\n RID didn't remain stable when RVALID is asserted and RREADY is low");

        // A value of X on RID is not permitted when RVALID is HIGH
        assert_AXI4_ERRS_RID_X : assert property (
            disable iff(!has_checks) 
            (rvalid == 1 |-> !$isunknown(rid)))
            else
            	$error("AXI4_ERRS_RID_X\n RID went to X or Z when RVALID is HIGH");

        // RDATA remains stable when RVALID is asserted and RREADY is LOW
        assert_AXI4_ERRS_RDATA_STABLE : assert property (
        	disable iff(!has_checks)
        	((rvalid == 1 && rready == 0) |=> $stable(rdata)))
        	else
        		$error("AXI4_ERRS_RDATA_STABLE\n RDATA didn't remain stable when RVALID is asserted and RREADY is low");

        // A value of X on RDATA is not permitted when RVALID is HIGH
        assert_AXI4_ERRS_RDATA_X : assert property (
            disable iff(!has_checks) 
            (rvalid == 1 |-> !$isunknown(rdata)))
            else
            	$error("AXI4_ERRS_RDATA_X\n RDATA went to X or Z when RVALID is HIGH");

        // RRESP remains stable when RVALID is asserted and RREADY is LOW
        assert_AXI4_ERRS_RRESP_STABLE : assert property (
        	disable iff(!has_checks)
        	((rvalid == 1 && rready == 0) |=> $stable(rresp)))
        	else
        		$error("AXI4_ERRS_RRESP_STABLE\n RRESP didn't remain stable when RVALID is asserted and RREADY is low");

        // A value of X on RRESP is not permitted when RVALID is HIGH
        assert_AXI4_ERRS_RRESP_X : assert property (
            disable iff(!has_checks) 
            (rvalid == 1 |-> !$isunknown(rresp)))
            else
            	$error("AXI4_ERRS_RRESP_X\n RRESP went to X or Z when RVALID is HIGH");

         // RLAST remains stable when RVALID is asserted and RREADY is LOW
        assert_AXI4_ERRS_RLAST_STABLE : assert property (
        	disable iff(!has_checks)
        	((rvalid == 1 && rready == 0) |=> $stable(rlast)))
        	else
        		$error("AXI4_ERRS_RLAST_STABLE\n RLAST didn't remain stable when RVALID is asserted and RREADY is low");

        // A value of X on RRESP is not permitted when RVALID is HIGH
        assert_AXI4_ERRS_RLAST_X : assert property (
            disable iff(!has_checks) 
            (rvalid == 1 |-> !$isunknown(rlast)))
            else
            	$error("AXI4_ERRS_RLAST_X\n RLAST went to X or Z when RVALID is HIGH");

        // RVALID is low for the first cycle after ARESETn goes HIGH
        /*assert_AXI4_ERRS_RVALID_RESET : assert property (
        	disable iff(!has_checks)
        	(@(negedge sig_reset) |=> rvalid == 0))
        	else
        		$error("AXI4_ERRS_RVALID_RESET\n RVALID not low for the first cycle after ARESETn goes HIGH");*/

        // When RVALID is asserted, then it remains asserted until RREADY is HIGH
       	/*assert_AXI4_ERRS_RVALID_STABLE : assert property (
       		disable iff(!has_checks)
       		)
       		else
        		$error("AXI4_ERRS_RVALID_STABLE\n RVALID was asserted, but it didn't remain asserted until RREADY is HIGH")*/

        // A value of X on RVALID is not permitted when not in reset
       	assert_AXI4_ERRS_RVALID_X : assert property (
        	disable iff(!has_checks)
        	(sig_reset == 0 |-> !$isunknown(rvalid)))
        	else
        		$error("AXI4_ERRS_RVALID_X\n RVALID went to X or Z when not in reset");

       	// A value of X on RREADY is not permitted when not in reset
       	assert_AXI4_ERRS_RREADY_X : assert property (
        	disable iff(!has_checks)
        	(sig_reset == 0 |-> !$isunknown(rready)))
        	else
        		$error("AXI4_ERRS_RREADY_X\n RREADY went to X or Z when not in reset");

       	// Recommended that RREADY is asserted within MAXWAITS cycles of RVALID being asserted
       	// A value of X on RUSER is not permitted when RVALID is HIGH

        // RUSER must be stable when RUSER_WIDTH has been set to zero

        // RID must be stable when ID_WIDTH has been set to zero
        assert_AXI4_ERRS_RID_TIEOFF : assert property (
        	disable iff(!has_checks)
        	(ID_WIDTH == 0 |-> $stable(rid)))
        	else
        		$error("AXI4_ERRS_RID_TIEOFF\n RID not stable when ID_WIDTH set to zero");



	end

endinterface : axi_if

`endif


