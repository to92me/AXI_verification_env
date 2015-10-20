// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : write_extension.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Andrea Erdeljan
*
* E-Mail : andrea.erdeljan@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : used for write extension
*
* Class : write_extension
**/
// -----------------------------------------------------------------------------

`ifndef WRITE_EXTENSION_SV
`define WRITE_EXTENSION_SV

// -----------------------------------------------------------------------------
//
// CLASS: write_extension
//
// -----------------------------------------------------------------------------
/** DESCRIPTION: write_extension is used for MIS callback
*					when writing 1 to MIS the corresponding field is set and an
*					instance of this class is send as the extention value in
*					the write task
**/
// -----------------------------------------------------------------------------
class write_extension extends uvm_object;

	bit overflow = 0;
	bit underflow = 0;
	bit match = 0;

	`uvm_object_utils(write_extension)

	// new - constructor
	function new(string name = "extension");
		super.new(name);
	endfunction : new

	// Get overflow
	function bit getOverflow();
		return overflow;
	endfunction

	// Set overflow
	function void setOverflow(bit overflow);
		this.overflow = overflow;
	endfunction

	// Get underflow
	function bit getUnderflow();
		return underflow;
	endfunction

	// Set underflow
	function void setUnderflow(bit underflow);
		this.underflow = underflow;
	endfunction

	// Get match
	function bit getMatch();
		return match;
	endfunction

	// Set match
	function void setMatch(bit match);
		this.match = match;
	endfunction

endclass

`endif