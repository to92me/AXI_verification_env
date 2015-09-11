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
* Description : synchronizer - for crossing clock domains
**/
// -----------------------------------------------------------------------------

module synchronizer 
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

endmodule : synchronizer