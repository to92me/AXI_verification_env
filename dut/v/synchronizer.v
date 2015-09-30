// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : synchronizer.v
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
* Description : synchronizers - for crossing clock domains
**/
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//
//	 Module: edge_detection
//
// -----------------------------------------------------------------------------
/**
* Description: scheme containing 4FFs used to catch a rising edge of the input
*				asynchronous signal; the module contains a strecher, a simple 2FF
*				synchronizer and an edge detector
*	- the input signal is used as the clock for the stretcher D FF. When a pulse
*	arrives, the stretcher D FF is loaded with ’ 1’. The output of the D FF is
*	then passed to the synchronizer. After the pulse is synchronized, the
*	asserted synchronizer output clears the first D FF via the asynchronous reset.
*	Due to the random one-clock delay of the synchronizer, the duration of the
*	synchronized output can be one or two clock periods, and thus an edge
*	detection circuit is needed to ensure correct operation.
*
* Ports:	1. input CLK - clk signal that the FFs are connected to (except the 1st)
*			2. input RESET - reset singal
*			3. input ASYNC_I - asynchronous signal that needs to be synchronized
*				(clk signal of the first FF)
*			4. output SYNC_O - synchronous output (output of the edge detecton scheme)
**/
// -----------------------------------------------------------------------------
module edge_detection 
	(
		input wire CLK,
		input wire RESET,
		input wire ASYNC_I,
		output wire SYNC_O
	);

	reg strecher;
	reg meta;
	reg sync;
	reg	edge_detector;
	reg	strecher_reset;

	assign SYNC_O = (edge_detector && (!sync));

	// strecher is used to catch the edge of the input signal
	// reset with global reset or with sync
	always @(posedge ASYNC_I or posedge strecher_reset or negedge RESET) begin
		if((strecher_reset) || (!RESET)) begin
			strecher <= 0;
		end
		else begin
			strecher <= 1;
		end
	end
	
	// strecher - 1 FF
	// synchronizer = 2 FFs (meta and sync)
	// edge detector - another FF
	// output of one FF is the input of the next
	always @(posedge CLK) begin
		if(RESET == 0) begin
			meta <= 0;
			sync <= 0;
			edge_detector <= 0;
			strecher_reset <= 0;
		end
		else begin
			meta <= strecher;
			sync <= meta;
			edge_detector <= sync;
			strecher_reset <= sync;
		end
	end

endmodule : edge_detection

// -----------------------------------------------------------------------------
//
//	 Module: simple_2ff_synchronizer
//
// -----------------------------------------------------------------------------
/**
* Description: synchronizer with 2 flip-flops connected so that the output
*				of the first ff is the input of the second
* Ports:	1. input CLK - clk signal that the FFs are connected to
*			2. input RESET - reset singal
*			3. input ASYNC_I - asynchronous signal that needs to be synchronized
*				(input of the first FF)
*			4. output SYNC_O - synchronous output (output of the second FF)
**/
// -----------------------------------------------------------------------------
module simple_2ff_synchronizer 
	(
		input wire CLK,
		input wire RESET,
		input wire ASYNC_I,
		output wire SYNC_O
	);

	reg meta;
	reg sync;

	assign SYNC_O = sync;
	
	// synchronizer = 2 FFs (meta and sync)
	always @(posedge CLK) begin
		if(RESET == 0) begin
			meta <= 0;
			sync <= 0;
		end
		else begin
			meta <= ASYNC_I;
			sync <= meta;
		end
	end

endmodule : simple_2ff_synchronizer