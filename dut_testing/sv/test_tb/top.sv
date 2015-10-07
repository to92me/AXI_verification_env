`ifndef DUT_REFERENCE_MODEL_TOP_SVH__
`define DUT_REFERENCE_MODEL_TOP_SVH__

// DUT
`include "dut/v/dut_counter.v"

//UVC and REGISTER MODEL
`include "axi_uvc/sv/axi_pkg.sv"
`include "dut_register_layer/sv/dut_register_model_pkg.sv"
`include "dut_testing/sv/register_model_env_pkg.sv"


//UVC VIF and DUT_REGISTER_MODEL VIF
`include "dut_register_layer/sv/dut_if.sv"
`include "axi_uvc/sv/axi_if.sv"

module dut_register_model_top;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import axi_pkg::*;

	import dut_register_model_pkg::*;

	import register_model_env_pkg::*;

    reg aclk;
    reg reset;
    reg fclk;
    reg counter_reset;

    axi_if if0(.sig_reset(reset), .sig_clock(aclk));
	dut_helper_vif if1(.sig_fclock(fclk), .sig_aclock(aclk), .sig_reset(reset));

    dut_counter # (
        .ID_WIDTH(RID_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .AWUSER_WIDTH(AWUSER_WIDTH),
        .ARUSER_WIDTH(ARUSER_WIDTH),
        .WUSER_WIDTH(WUSER_WIDTH),
        .RUSER_WIDTH(RUSER_WIDTH),
        .BUSER_WIDTH(BUSER_WIDTH)
    ) dut_counter_inst (
        .AXI_ACLK(aclk),
        .AXI_ARESETN(reset),
        .AXI_AWID(if0.awid),
        .AXI_AWADDR(if0.awaddr),
        .AXI_AWLEN(if0.awlen),
        .AXI_AWSIZE(if0.awsize),
        .AXI_AWBURST(if0.awburst),
        .AXI_AWLOCK(if0.awlock),
        .AXI_AWCACHE(if0.awcache),
        .AXI_AWPROT(if0.awprot),
        .AXI_AWQOS(if0.awqos),
        .AXI_AWREGION(if0.awregion),
        .AXI_AWUSER(if0.awuser),
        .AXI_AWVALID(if0.awvalid),
        .AXI_AWREADY(if0.awready),
        .AXI_WDATA(if0.wdata),
        .AXI_WSTRB(if0.wstrb),
        .AXI_WLAST(if0.wlast),
        .AXI_WUSER(if0.wuser),
        .AXI_WVALID(if0.wvalid),
        .AXI_WREADY(if0.wready),
        .AXI_BID(if0.bid),
        .AXI_BRESP(if0.bresp),
        .AXI_BUSER(if0.buser),
        .AXI_BVALID(if0.bvalid),
        .AXI_BREADY(if0.bready),
        .AXI_ARID(if0.arid),
        .AXI_ARADDR(if0.araddr),
        .AXI_ARLEN(if0.arlen),
        .AXI_ARSIZE(if0.arsize),
        .AXI_ARBURST(if0.arburst),
        .AXI_ARLOCK(if0.arlock),
        .AXI_ARCACHE(if0.arcache),
        .AXI_ARPROT(if0.arprot),
        .AXI_ARQOS(if0.arqos),
        .AXI_ARREGION(if0.arregion),
        .AXI_ARUSER(if0.aruser),
        .AXI_ARVALID(if0.arvalid),
        .AXI_ARREADY(if0.arready),
        .AXI_RID(if0.rid),
        .AXI_RDATA(if0.rdata),
        .AXI_RRESP(if0.rresp),
        .AXI_RLAST(if0.rlast),
        .AXI_RUSER(if0.ruser),
        .AXI_RVALID(if0.rvalid),
        .AXI_RREADY(if0.rready),
        .FCLK(fclk),
        .IRQ_O(if1.irq),
        .DOUT_O(if1.dout),
        .RESET_I(counter_reset),
        .SWRESET_O(if1.swreset)
    );

    initial begin
        uvm_config_db#(virtual axi_if)::set(null,"uvm_test_top.*","vif", if0);
	    uvm_config_db#(virtual dut_helper_vif)::set(null,"uvm_test_top.*","dut_vif", if1);
        run_test("dut_register_model_test_base");
    end

    initial begin
        reset <= 1'b0;
	 	aclk <= 1'b0;
	    fclk <= 1'b0;
	    #5 reset <= 1'b1;
    end

    //Generate f clock
    always begin
        #10 fclk = ~fclk;
    end

    //Generate a clock
    always begin
        #5 aclk = ~aclk;
    end

endmodule
`endif
