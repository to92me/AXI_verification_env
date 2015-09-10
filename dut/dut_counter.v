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
    	output wire DOUT_O  // active when count > LOAD
	);

// -----------------------------------------------------------------------------
//
//	 Registers
//
// -----------------------------------------------------------------------------

	// signal registers
	// axi
	reg [ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg [BUSER_WIDTH-1 : 0] 	axi_buser;
	reg  	axi_bvalid;
	reg [ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg [RUSER_WIDTH-1 : 0] 	axi_ruser;
	reg  	axi_rvalid;
	reg [2 : 0]		axi_awprot;
	// counter
	reg 	irq_o;
	reg 	dout_o;

	// helper registers
	reg 	read_flag;	// set when a read request has been accepted
	reg 	write_addr_flag;	// set when a valid address has been sent
	reg 	write_data_flag;	// set when data has been sent
	reg 	bready_flag;	// set when axi_bready is set
	reg 	rready_flag;	// set when axi_rready is set

	// counter registers
	reg 	nrst;  // internal signal generated based on SWRESET
    reg [DATA_WIDTH : 0]	count;
    // unused bits are reserved, read-only, value=0
    reg [DATA_WIDTH : 0]	RIS; // bit 0 - OVERFLOW, bit 1 - UNDERFLOW; read-only
    reg [DATA_WIDTH : 0]	IM;  // bit 0 - OVERFLOW, bit 1 - UNDERFLOW; read-write
    reg [DATA_WIDTH : 0]	MIS; // bit 0 - OVERFLOW, bit 1 - UNDERFLOW; write 1 deletes flags in MIS and RIS
    reg [DATA_WIDTH : 0]	LOAD;    // 16-bit value; read-write
    reg [DATA_WIDTH : 0]	CFG; // bit 0 - counter enable, bit 1 - up(0)/down(1); read-write

	// I/O Connections assignments
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
	assign AXI_BUSER = 0;
	assign IRQ_O = irq_o;
	assign DOUT_O = dout_o;

	// start state
	initial begin
        count = 15'b0;
        RIS = 0;
        IM = 0;
        MIS = 0;
        LOAD = 0;
        CFG = 0;
    end

// -----------------------------------------------------------------------------
//
//	 Read address channel
//
// -----------------------------------------------------------------------------
	always @(posedge AXI_ACLK iff AXI_ARESETN == 1) begin
		axi_arready <= 1'b1;	// slave always ready to accept requests

		if(AXI_ARVALID) begin
			axi_rresp = 2'b00;	// default response - OKAY

			case (AXI_ARADDR)
				0:	// RIS
					axi_rdata <= RIS;
				2:	// IM
					axi_rdata <= IM;
				4:	// MIS
					axi_rdata <= MIS;
				6:	// LOAD
					axi_rdata <= LOAD;
				8: //CFG
					axi_rdata <= CFG;
				10:	// SWRESET
					axi_rdata <= 0;
				12:	// count
					axi_rdata <= count;
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
			if(AXI_ARSIZE != 3'b01)
				axi_rresp <= 2'b10;	// SLVERR
			// burst type not fixed
			if(AXI_ARBURST)
				axi_rresp <= 2'b10;	// SLVERR

			read_flag <= 1; // ILI AXI_ARLEN - DA LI JE DOZVOLJENA TERMINACIJA BURST-OVA - ASK DARKO
		end
	end

// -----------------------------------------------------------------------------
//
//	 Read data channel
//
// -----------------------------------------------------------------------------
	always @(posedge AXI_ACLK iff AXI_ARESETN == 1) begin
		// send response
		if(read_flag || !rready_flag) begin
			read_flag = 0;	// ILI READ_FLAG-- AKO IH IMA VISE
			rready_flag = 0;
			axi_rvalid = 1;
			if(AXI_RREADY)
				rready_flag = 1;
		end
		else
			axi_rvalid = 0;
	end

// -----------------------------------------------------------------------------
//
//	Write address channel
//
// -----------------------------------------------------------------------------
	always @(posedge AXI_ACLK iff AXI_ARESETN == 1) begin
		axi_awready = 1;	// slave always ready

		if(AXI_AWVALID) begin

			// check and get address
			if (AXI_AWADDR inside {2, 4, 6, 8, 10, 12}) begin
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
			if(AXI_AWSIZE != 3'b01)
				write_addr_flag <= 0;
			// burst type not fixed
			if(AXI_AWBURST)
				write_addr_flag <= 0;
		end
	end

// -----------------------------------------------------------------------------
//
//	Write data channel
//
// -----------------------------------------------------------------------------
	always @(posedge AXI_ACLK iff AXI_ARESETN == 1) begin
		axi_wready = 1;	// slave always ready

		if(AXI_WVALID) begin
			if(write_addr_flag) begin
				write_addr_flag = 0;
				axi_bresp <= 2'b00;	// default OKAY response

				case (axi_awaddr)
					2:	// IM
						IM[1:0]	= AXI_WDATA[1:0];
					4:	// MIS - writing allowed only if PROT = 1
						// sending 1 to a valid bit location deletes the flags
						// in MIS and RIS registers
						// 0 does nothing
						if (axi_awprot == 3'b001) begin
							if(AXI_WDATA[0] == 1) begin
								MIS[0] = 0;
								RIS[0] = 0;
							end
							if(AXI_WDATA[1] == 1) begin
								MIS[1] = 0;
								RIS[1] = 0;
							end
						end
						else
							axi_bresp <= 2'b10;	// slverr
					6:	// LOAD
						LOAD = AXI_WDATA;
					8: //CFG
						CFG[1:0] = AXI_WDATA[1:0];
					10:	// SWRESET - writing 0x5a resets all registers
						if(AXI_WDATA == 'b0000000001011010)
							nrst = 1;
						else
							axi_bresp <= 2'b10;	// slverr
					12:	// count
						count = AXI_WDATA;
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
	end

// -----------------------------------------------------------------------------
//
//	Write response channel
//
// -----------------------------------------------------------------------------
	always @(posedge AXI_ACLK iff AXI_ARESETN == 1) begin
		if(write_data_flag || !bready_flag) begin
			write_data_flag = 0;
			bready_flag = 0;
			axi_bvalid = 1;
			if(AXI_BREADY)
				bready_flag = 1;
		end
		else
			axi_bvalid = 0;
	end

// -----------------------------------------------------------------------------
//
//	Counter
//
// -----------------------------------------------------------------------------
	always @(posedge FCLK or negedge AXI_ARESETN) begin

        if(!AXI_ARESETN || nrst) begin
            count = 0;
            RIS = 0;
            IM = 0;
            MIS = 0;
            LOAD = 0;
            CFG = 0;
            irq_o = 0;
            dout_o = 0;
            nrst = 0;
        end
        else begin
            if(CFG[0] == 1) begin // counter enable
            	// default values
        		RIS[0] = 0;
       			RIS[1] = 0;
                if(CFG[1] == 0) begin // up
                    if(count == 15'b1)  // OVERFLOW
                        RIS[0] = 1;
                    count = count + 1;
                end
                else begin  // down
                    if(count == 0)  // UNDERFLOW
                        RIS[1] = 1;
                    count = count - 1;
                end
            end

            // MIS calculation
            MIS[0] = RIS[0] && IM[0];
            MIS[1] = RIS[1] && IM[1];
            if(MIS[0] || MIS[1])
                irq_o = 1;
            else
                irq_o = 0;

            // LOAD check
            if (count > LOAD)
                dout_o = 1;
            else
                dout_o = 0;
        end
    end

endmodule