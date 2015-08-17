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

endinterface : axi_if

`endif


