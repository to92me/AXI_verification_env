// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : dut_counter.v
*
* Language : Verilog
*
* Company : Elsys Eastern Europe
*
* Author : Andrea Erdeljan
*
* E-Mail : andrea.erdeljan@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : design under test - slave interface
**/
// -----------------------------------------------------------------------------

`include "dut/v/synchronizer.v"

module dut_counter #
	(
		// Width of ID for for write address, write data, read address and read data
		parameter integer ID_WIDTH	= 1,
		// Width of AXI data bus
		parameter integer DATA_WIDTH	= 16,
		// Width of AXI address bus
		parameter integer ADDR_WIDTH	= 6,
		// Width of optional user defined signal in write address channel
		parameter integer AWUSER_WIDTH	= 0,
		// Width of optional user defined signal in read address channel
		parameter integer ARUSER_WIDTH	= 0,
		// Width of optional user defined signal in write data channel
		parameter integer WUSER_WIDTH	= 0,
		// Width of optional user defined signal in read data channel
		parameter integer RUSER_WIDTH	= 0,
		// Width of optional user defined signal in write response channel
		parameter integer BUSER_WIDTH	= 0
	)
	(
		// Global Clock Signal
		input wire  AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  AXI_ARESETN,
		// Write Address ID
		input wire [ID_WIDTH-1 : 0] AXI_AWID,
		// Write address
		input wire [ADDR_WIDTH-1 : 0] AXI_AWADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		input wire [7 : 0] AXI_AWLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		input wire [2 : 0] AXI_AWSIZE,
		// Burst type. The burst type and the size information,
    	// determine how the address for each transfer within the burst is calculated.
		input wire [1 : 0] AXI_AWBURST,
		// Lock type. Provides additional information about the
    	// atomic characteristics of the transfer.
		input wire  AXI_AWLOCK,
		// Memory type. This signal indicates how transactions
    	// are required to progress through a system.
		input wire [3 : 0] AXI_AWCACHE,
		// Protection type. This signal indicates the privilege
    	// and security level of the transaction, and whether
    	// the transaction is a data access or an instruction access.
		input wire [2 : 0] AXI_AWPROT,
		// Quality of Service, QoS identifier sent for each
    	// write transaction.
		input wire [3 : 0] AXI_AWQOS,
		// Region identifier. Permits a single physical interface
    	// on a slave to be used for multiple logical interfaces.
		input wire [3 : 0] AXI_AWREGION,
		// Optional User-defined signal in the write address channel.
		input wire [AWUSER_WIDTH-1 : 0] AXI_AWUSER,
		// Write address valid. This signal indicates that
    	// the channel is signaling valid write address and
    	// control information.
		input wire  AXI_AWVALID,
		// Write address ready. This signal indicates that
    	// the slave is ready to accept an address and associated
    	// control signals.
		output wire  AXI_AWREADY,
		// Write Data
		input wire [DATA_WIDTH-1 : 0] AXI_WDATA,
		// Write strobes. This signal indicates which byte
    	// lanes hold valid data. There is one write strobe
    	// bit for each eight bits of the write data bus.
		input wire [(DATA_WIDTH/8)-1 : 0] AXI_WSTRB,
		// Write last. This signal indicates the last transfer
    	// in a write burst.
		input wire  AXI_WLAST,
		// Optional User-defined signal in the write data channel.
		input wire [WUSER_WIDTH-1 : 0] AXI_WUSER,
		// Write valid. This signal indicates that valid write
	    // data and strobes are available.
		input wire  AXI_WVALID,
		// Write ready. This signal indicates that the slave
    	// can accept the write data.
		output wire  AXI_WREADY,
		// Response ID tag. This signal is the ID tag of the
	    // write response.
		output wire [ID_WIDTH-1 : 0] AXI_BID,
		// Write response. This signal indicates the status
    	// of the write transaction.
		output wire [1 : 0] AXI_BRESP,
		// Optional User-defined signal in the write response channel.
		output wire [BUSER_WIDTH-1 : 0] AXI_BUSER,
		// Write response valid. This signal indicates that the
	    // channel is signaling a valid write response.
		output wire  AXI_BVALID,
		// Response ready. This signal indicates that the master
	    // can accept a write response.
		input wire  AXI_BREADY,
		// Read address ID. This signal is the identification
    	// tag for the read address group of signals.
		input wire [ID_WIDTH-1 : 0] AXI_ARID,
		// Read address. This signal indicates the initial
    	// address of a read burst transaction.
		input wire [ADDR_WIDTH-1 : 0] AXI_ARADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		input wire [7 : 0] AXI_ARLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		input wire [2 : 0] AXI_ARSIZE,
		// Burst type. The burst type and the size information,
    	// determine how the address for each transfer within the burst is calculated.
		input wire [1 : 0] AXI_ARBURST,
		// Lock type. Provides additional information about the
    	// atomic characteristics of the transfer.
		input wire  AXI_ARLOCK,
		// Memory type. This signal indicates how transactions
    	// are required to progress through a system.
		input wire [3 : 0] AXI_ARCACHE,
		// Protection type. This signal indicates the privilege
    	// and security level of the transaction, and whether
	    // the transaction is a data access or an instruction access.
		input wire [2 : 0] AXI_ARPROT,
		// Quality of Service, QoS identifier sent for each
    	// read transaction.
		input wire [3 : 0] AXI_ARQOS,
		// Region identifier. Permits a single physical interface
    	// on a slave to be used for multiple logical interfaces.
		input wire [3 : 0] AXI_ARREGION,
		// Optional User-defined signal in the read address channel.
		input wire [ARUSER_WIDTH-1 : 0] AXI_ARUSER,
		// Write address valid. This signal indicates that
    	// the channel is signaling valid read address and
	    // control information.
		input wire  AXI_ARVALID,
		// Read address ready. This signal indicates that
    	// the slave is ready to accept an address and associated
    	// control signals.
		output wire  AXI_ARREADY,
		// Read ID tag. This signal is the identification tag
    	// for the read data group of signals generated by the slave.
		output wire [ID_WIDTH-1 : 0] AXI_RID,
		// Read Data
		output wire [DATA_WIDTH-1 : 0] AXI_RDATA,
		// Read response. This signal indicates the status of
    	// the read transfer.
		output wire [1 : 0] AXI_RRESP,
		// Read last. This signal indicates the last transfer
    	// in a read burst.
		output wire  AXI_RLAST,
		// Optional User-defined signal in the read address channel.
		output wire [RUSER_WIDTH-1 : 0] AXI_RUSER,
		// Read valid. This signal indicates that the channel
    	// is signaling the required read data.
		output wire  AXI_RVALID,
		// Read ready. This signal indicates that the master can
    	// accept the read data and response information.
		input wire  AXI_RREADY,

		// Counter
		input wire FCLK, // used for counting
    	output wire IRQ_O,   // active when any bit in MIS is active
    	output wire DOUT_O,  // active when count > LOAD
    	input wire RESET_I	// reset counter on rising edge
	);

// -----------------------------------------------------------------------------
//
//	 Registers
//
// -----------------------------------------------------------------------------

	// --------------------------------------------------------------------------------------
	// signal registers
	// --------------------------------------------------------------------------------------
	// axi
	reg [ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  					axi_awready;
	reg  					axi_wready;
	reg [1 : 0] 			axi_bresp;
	reg [BUSER_WIDTH-1 : 0] axi_buser;
	reg  					axi_bvalid;
	reg  					axi_arready;
	reg [DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 			axi_rresp;
	reg [RUSER_WIDTH-1 : 0]	axi_ruser;
	reg  					axi_rvalid;
	reg [2 : 0]				axi_awprot;
	// counter
	reg 	irq_o;
	reg 	dout_o;

	// --------------------------------------------------------------------------------------
	// helper registers
	// --------------------------------------------------------------------------------------
	reg 	read_flag;	// set when a read request has been accepted
	reg 	write_addr_flag;	// set when a valid address has been sent
	reg 	write_data_flag;	// set when data has been sent
	reg 	bready_flag;	// set when axi_bready is set
	reg 	rready_flag;	// set when axi_rready is set

	// counter registers
	// unused bits are reserved, read-only, value=0
	// --------------------------------------------------------------------------------------
	// ACLK domain
	// --------------------------------------------------------------------------------------
	reg 					nrst;  // internal signal generated based on SWRESET
    reg [DATA_WIDTH-1 : 0]	RIS; // bit 0 - OVERFLOW, bit 1 - UNDERFLOW; bit 2 - MATCH; read-only
    reg [DATA_WIDTH-1 : 0]	IM;  // bit 0 - OVERFLOW, bit 1 - UNDERFLOW; bit 2 - MATCH; read-write
    reg [DATA_WIDTH-1 : 0]	MIS; // bit 0 - OVERFLOW, bit 1 - UNDERFLOW; bit 2 - MATCH; write 1 deletes flags in MIS and RIS
    reg [DATA_WIDTH-1 : 0]	LOAD;    // counter compared to this value; read-write
    reg [DATA_WIDTH-1 : 0]	CFG; // bit 0 - counter enable, bit 1 - up(0)/down(1); read-write
    reg [DATA_WIDTH-1 : 0]	IIR;	// interrupt index registar; read-only
    reg [DATA_WIDTH-1 : 0]	MATCH;	//  counter compared to this value; read-write
    reg [DATA_WIDTH-1 : 0]	count_aclk;	// register that holds the count value
    // synchronization
    wire					ris0_sync;	// for RIS[0]
    wire					ris1_sync;	// for RIS[1]
    wire 					ris2_sync;	// for RIS[2]
    reg 					cfg0_async;	// for CFG[0]
    reg 					cfg1_async;	// for CFG[1]
    wire 					dout_sync;	// for dout_o
    // handshaking protocol
    wire					req_sync;	// synchronized request
    reg 					ack;	// acknowledgement of the req signal
    reg [2*DATA_WIDTH-1 : 0] data_bus_pull;	// the values of load and match are placed here

    // --------------------------------------------------------------------------------------
	// FCLK domain
	// --------------------------------------------------------------------------------------
    reg [DATA_WIDTH-1 : 0]	count;	// counter reg.
    // synchronization
    wire 					nrst_sync;	// for nrst
    reg 					ris0_async;	// for RIS[0]
    reg 					ris1_async;	// for RIS[1]
    reg 					ris2_async;	// for RIS[2]
    wire					cfg0_sync;	// for CFG[0]
    wire					cfg1_sync;	// for CFG[1]
    reg [DATA_WIDTH-1 : 0]	load_fclk;	// holds the LOAD value
    reg [DATA_WIDTH-1 : 0]	match_fclk;	// holds the MATCH value
    reg 					dout_async;	// for the dout_o output signal
    // for the handshaking protocol
    reg 					req;	// request
    wire					ack_sync;	// synchronized acknowledgement
    reg [DATA_WIDTH-1 : 0]	data_bus_push;	// where the value of count will be placed

    // the two-phase handshaking protocol between the two clock domains is as follows:
    // the push operation:
    // The talker activates the req signal and places data on the data bus
    // The listener detects activation of the req signal. It retrieves the data and activates the ack signal
    // Once the talker senses activation of the ack signal, it removes the data from the data bus.
    // The first push operation is done at this point. When the talker wants to push the next data, the handshaking continues from this state
    // The talker deactivates the req signal and places data on the data bus.
    // The listener detects deactivation of the req signal. It retrieves the data and deactivates the ack signal.
    // Once the talker senses deactivation of the ack signal, it removes the data from the data bus.
    // the pull operation:
    // When the talker initiates a new data transfer, it implicitly indicates that the data from the previous pull
	// operation has been retrieved. when the listener detects the transition of the req signal of the next operation, it can safely remove
	// the data from the data bus
    // separate data lines are needed for the push and pull operations

// -----------------------------------------------------------------------------
//
//	 Synchronizers
//
// -----------------------------------------------------------------------------
    // RIS[0]
	edge_detection sync_ris0 (
		.CLK(AXI_ACLK),
		.RESET(AXI_ARESETN && (!nrst)),
		.ASYNC_I(ris0_async),
		.SYNC_O(ris0_sync)
	);
	// RIS[1]
	edge_detection sync_ris1 (
		.CLK(AXI_ACLK),
		.RESET(AXI_ARESETN && (!nrst)),
		.ASYNC_I(ris1_async),
		.SYNC_O(ris1_sync)
	);
	// RIS[2]
	edge_detection sync_ris2 (
		.CLK(AXI_ACLK),
		.RESET(AXI_ARESETN && (!nrst)),
		.ASYNC_I(ris2_async),
		.SYNC_O(ris2_sync)
	);

	// CFG[0]
	simple_2ff_synchronizer sync_cfg0 (
		.CLK(FCLK),
		.RESET((!nrst_sync) && (!reset_counter_sync)),
		.ASYNC_I(cfg0_async),
		.SYNC_O(cfg0_sync)
	);
	// CFG[1]
	simple_2ff_synchronizer sync_cfg1 (
		.CLK(FCLK),
		.RESET((!nrst_sync) && (!reset_counter_sync)),
		.ASYNC_I(cfg1_async),
		.SYNC_O(cfg1_sync)
	);

	// nrst
	edge_detection sync_nrst (
		.CLK(FCLK),
		.RESET((!nrst_sync) && (!reset_counter_sync)),
		.ASYNC_I(nrst),
		.SYNC_O(nrst_sync)
	);

	// 2-phase handshaking protocol for the counter data
	simple_2ff_synchronizer sync_req (
		.CLK(AXI_ACLK),
		.RESET(AXI_ARESETN && (!nrst)),
		.ASYNC_I(req),
		.SYNC_O(req_sync)
	);
	simple_2ff_synchronizer sync_ack (
		.CLK(FCLK),
		.RESET((!nrst_sync) && (!reset_counter_sync)),
		.ASYNC_I(ack),
		.SYNC_O(ack_sync)
	);

	// counter reset on edge
	edge_detection sync_reset (
		.CLK(FCLK),
		.RESET((!nrst_sync) && (!reset_counter_sync)),
		.ASYNC_I(RESET_I),
		.SYNC_O(reset_counter_sync)
	);

	// load check - dout_o
	simple_2ff_synchronizer sync_dout (
		.CLK(AXI_ACLK),
		.RESET(AXI_ARESETN && (!nrst)),
		.ASYNC_I(dout_async),
		.SYNC_O(dout_sync)
	);

// -----------------------------------------------------------------------------
//
//	 I/O Connections assignments
//
// -----------------------------------------------------------------------------
	assign AXI_AWREADY	= axi_awready;
	assign AXI_WREADY	= axi_wready;
	assign AXI_BRESP	= axi_bresp;
	assign AXI_BUSER	= axi_buser;
	assign AXI_BVALID	= axi_bvalid;
	assign AXI_ARREADY	= axi_arready;
	assign AXI_RDATA	= axi_rdata;
	assign AXI_RRESP	= axi_rresp;
	assign AXI_RLAST	= 1;	// len always 1
	assign AXI_RUSER	= axi_ruser;
	assign AXI_RVALID	= axi_rvalid;
	assign AXI_BID = AXI_AWID;
	assign AXI_RID = AXI_ARID;
	assign IRQ_O = irq_o;
	assign DOUT_O = dout_o;

	// start state
	initial begin
		// fclk
        count <= 0;
		ris0_async <= 0;
		ris1_async <= 0;
		req <= 0;
		data_bus_push <= 0;

		// aclk
		axi_awready <= 1;
    	axi_wready <= 0;
    	axi_bresp <= 0;
    	axi_buser <= 0;
    	axi_bvalid <= 0;
    	axi_arready <= 1;
    	axi_rdata <= 0;
    	axi_rresp <= 0;
    	axi_ruser <= 0;
    	axi_rvalid <= 0;

    	read_flag <= 0;
		write_addr_flag <= 0;
		write_data_flag <= 0;
		bready_flag <= 1;
		rready_flag <= 1;

		RIS <= 0;
        IM <= 0;
        MIS <= 0;
        IIR <= 0;
        LOAD <= 0;
        MATCH <= 0;
        CFG <= 0;
        irq_o <= 0;
        dout_o <= 0;
        nrst <= 0;
		cfg0_async <= 0;
		cfg1_async <= 0;
		ack <= 0;
		count_aclk <= 0;
		data_bus_pull <= 0;
    end

always @(posedge AXI_ACLK) begin

// -----------------------------------------------------------------------------
//
//	 Reset
//
// -----------------------------------------------------------------------------
    // reset axi signals
    if (AXI_ARESETN == 0) begin
    	axi_awready <= 1;
    	axi_wready <= 0;
    	axi_bresp <= 0;
    	axi_buser <= 0;
    	axi_bvalid <= 0;
    	axi_arready <= 1;
    	axi_rdata <= 0;
    	axi_rresp <= 0;
    	axi_ruser <= 0;
    	axi_rvalid <= 0;

    	// reset flags
	    read_flag <= 0;
		write_addr_flag <= 0;
		write_data_flag <= 0;
		bready_flag <= 1;
		rready_flag <= 1;

    end

    // reset registers
    if ((AXI_ARESETN == 0) || (nrst == 1)) begin
        RIS <= 0;
        IM <= 0;
        MIS <= 0;
        IIR <= 0;
        LOAD <= 0;
        MATCH <= 0;
        CFG <= 0;
        irq_o <= 0;
        dout_o <= 0;
        nrst <= 0;
		cfg0_async <= 0;
		cfg1_async <= 0;
		ack <= 0;
		count_aclk <= 0;
		data_bus_pull <= 0;
    end


    else begin	// if reset not asserted
// -----------------------------------------------------------------------------
//
//	Register assigments
//
// -----------------------------------------------------------------------------
    	// first check if RIS is set (so that risX_sync doen't clear it)
    	if (!RIS[0])
			RIS[0] <= ris0_sync;
		if (!RIS[1])
			RIS[1] <= ris1_sync;
		if (!RIS[2])
			RIS[2] <= ris2_sync;

		// MIS calculation
	    MIS[0] <= RIS[0] && IM[0];
	    MIS[1] <= RIS[1] && IM[1];
	    MIS[2] <= RIS[2] && IM[2];
	    if(MIS[0] || MIS[1] || MIS[2])
	        irq_o <= 1;
	    else
	        irq_o <= 0;

	    // CFG
	    cfg0_async <= CFG[0];
	    cfg1_async <= CFG[1];

	   	// LOAD check
	    dout_o <= dout_sync;

	    // IIR
	    case (MIS[2:0])
	    	3'b000:	begin
	    				IIR[2:0] <= 3'b000;
	    			end
			3'b001: begin
						IIR[2:0] <= 3'b001;
					end
	    	3'b010: begin
	    				IIR[2:0] <= 3'b010;
	    			end
	    	3'b011: begin
	    				IIR[2:0] <= 3'b010;
	    			end
	    	3'b100: begin
	    				IIR[2:0] <= 3'b011;
	    			end
	    	3'b101: begin
	    				IIR[2:0] <= 3'b011;
	    			end
	    	3'b110: begin
	    				IIR[2:0] <= 3'b011;
	    			end
	    	3'b111: begin
	    				IIR[2:0] <= 3'b011;
	    			end
	    endcase

	    // handshaking protocol
	    if(ack != req_sync) begin
	    	count_aclk <= data_bus_push;
	    	data_bus_pull <= {LOAD, MATCH};
	    	ack <= !ack;
	    end

// -----------------------------------------------------------------------------
//
//	 Read address channel
//
// -----------------------------------------------------------------------------
		axi_arready <= 1'b1;	// slave always ready to accept requests

		if(AXI_ARVALID) begin
			axi_rresp <= 2'b00;	// default response - OKAY

			case (AXI_ARADDR)
				0:	// RIS
					axi_rdata <= RIS;
				2:	// IM
					axi_rdata <= IM;
				4:	// MIS
					axi_rdata <= MIS;
				6:	// LOAD
					axi_rdata <= LOAD;
				8:	// CFG
					axi_rdata <= CFG;
				10:	// SWRESET
					axi_rdata <= 0;
				12: // IIR
					begin
						case (IIR[2:0])
							//3'b000:	// no interrupts
							3'b001:	RIS[0] <= 0;
							3'b010: RIS[1] <= 0;
							3'b100: RIS[2] <= 0;
						endcase
						axi_rdata <= IIR;
					end
				14: // MATCH
					axi_rdata <= MATCH;
				16:	// count
					axi_rdata <= count_aclk;
				default:
					begin
						// unimplemented address
						axi_rdata <= 0;
						axi_rresp <= 2'b10;	// SLVERR
					end
			endcase

			// checks
			// if burst is more than 1 transfer
			if(AXI_ARLEN)
				axi_rresp <= 2'b10;	// SLVERR
			// size not 16 bits
			if(AXI_ARSIZE != 3'b001)
				axi_rresp <= 2'b10;	// SLVERR
			// burst type not fixed
			if(AXI_ARBURST)
				axi_rresp <= 2'b10;	// SLVERR

			read_flag <= 1;
		end
		else
			read_flag <= 0;

// -----------------------------------------------------------------------------
//
//	 Read data channel
//
// -----------------------------------------------------------------------------
		// send response
		if(read_flag || !rready_flag) begin
			rready_flag <= 0;
			axi_rvalid <= 1;
			if(AXI_RREADY)
				rready_flag <= 1;
		end
		else
			axi_rvalid <= 0;

// -----------------------------------------------------------------------------
//
//	Write address channel
//
// -----------------------------------------------------------------------------
		axi_awready <= 1;	// slave always ready

		if(AXI_AWVALID) begin

			// check and get address
			if ((AXI_AWADDR == 2) || (AXI_AWADDR == 4) || (AXI_AWADDR == 6) || (AXI_AWADDR == 8) || (AXI_AWADDR == 10) || (AXI_AWADDR == 14)) begin
				axi_awaddr <= AXI_AWADDR;
				axi_awprot <= AXI_AWPROT;
				write_addr_flag <= 1;
			end
			else begin
				write_addr_flag <= 0;
			end

			// checks
			// if burst is more than 1 transfer
			if(AXI_AWLEN)
				write_addr_flag <= 0;
			// size not 16 bits
			if(AXI_AWSIZE != 3'b001)
				write_addr_flag <= 0;
			// burst type not fixed
			if(AXI_AWBURST)
				write_addr_flag <= 0;

		end

// -----------------------------------------------------------------------------
//
//	Write data channel
//
// -----------------------------------------------------------------------------
		axi_wready <= 1;	// slave always ready

		if(AXI_WVALID) begin
			if(write_addr_flag) begin
				write_addr_flag <= 0;

				axi_bresp <= 2'b00;	// default OKAY response

				case (axi_awaddr)
					2:	// IM
						IM[2:0]	<= AXI_WDATA[2:0];
					4:	// MIS - writing allowed only if PROT = 1
						// sending 1 to a valid bit location deletes the flags
						// in MIS and RIS registers
						// 0 does nothing
						if (axi_awprot == 3'b001) begin
							if(AXI_WDATA[0] == 1) begin
								MIS[0] <= 0;
								RIS[0] <= 0;
							end
							if(AXI_WDATA[1] == 1) begin
								MIS[1] <= 0;
								RIS[1] <= 0;
							end
							if(AXI_WDATA[2] == 1) begin
								MIS[2] <= 0;
								RIS[2] <= 0;
							end
						end
						else
							axi_bresp <= 2'b10;	// slverr
					6:	// LOAD
						LOAD <= AXI_WDATA;
					8: //CFG
						CFG[1:0] <= AXI_WDATA[1:0];
					10:	// SWRESET - writing 0x5a resets all registers
						if(AXI_WDATA == 'b0000000001011010)
							nrst <= 1;
						else
							axi_bresp <= 2'b10;	// slverr
					14: // MATCH
						MATCH <= AXI_WDATA;
				endcase
				write_data_flag <= 1;
			end

			else begin
				axi_bresp <= 2'b10;	// slverr
				write_data_flag <= 1;
			end
		end
		else
			write_data_flag <= 0;

// -----------------------------------------------------------------------------
//
//	Write response channel
//
// -----------------------------------------------------------------------------
		if(write_data_flag || !bready_flag) begin
			bready_flag <= 0;
			axi_bvalid <= 1;
			if(AXI_BREADY)
				bready_flag <= 1;
		end
		else
			axi_bvalid <= 0;


	end // else begin (AXI_ARESETN == 1)
end 	// always @(posedge AXI_ACLK)

// -----------------------------------------------------------------------------
//
//	Counter
//
// -----------------------------------------------------------------------------
always @(posedge FCLK) begin

	// default
	ris0_async <= 0;
	ris1_async <= 0;

	// RESET
	if ((reset_counter_sync == 1) || (nrst_sync == 1)) begin
		count <= 0;
		ris0_async <= 0;
		ris1_async <= 0;
		req <= 0;
		data_bus_push <= 0;
		load_fclk <= 0;
		match_fclk <= 0;
		dout_async <= 0;
	end
	else begin
        if(cfg0_sync == 1) begin // counter enable

            if(cfg1_sync == 0) begin // up

                if(count == 16'b1111111111111111)  // OVERFLOW
                    ris0_async <= 1;
                count <= count + 1;

            end
            else begin  // down

                if(count == 0)  // UNDERFLOW
                    ris1_async <= 1;
                count <= count - 1;

            end
        end
	end

	// MATCH check
	if(match_fclk == count)
		ris2_async <= 1;
	else
		ris2_async <= 0;

	// LOAD check
	if(count > load_fclk)
		dout_async <= 1;
	else
		dout_async <= 0;

	// handshaking protocol
	if(ack_sync == req) begin
		req <= !req;
		data_bus_push <= count;
		load_fclk <= data_bus_pull[2*DATA_WIDTH-1 : DATA_WIDTH];
		match_fclk <= data_bus_pull[DATA_WIDTH-1 : 0];
	end
end

endmodule
