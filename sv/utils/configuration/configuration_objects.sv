`ifndef AXI_CONFIGURATION_OBJECTS_SVH
`define AXI_CONFIGURATION_OBJECTS_SVH

//------------------------------------------------------------------------------
//
// CLASS: AXI_CONFIGURATION_OBJECTS_SVH
//
//------------------------------------------------------------------------------

class axi_depth_config;
	int 				depth = 5;
	true_false_enum		deept_exists = TRUE;

	// Get deept_exists
	function true_false_enum getDeept_exists();
		return deept_exists;
	endfunction

	// Set deept_exists
	function void setDeept_exists(true_false_enum deept_exists);
		this.deept_exists = deept_exists;
	endfunction

	// Get depth
	function int getdepth();
		return depth;
	endfunction

	// Set depth
	function void setdepth(int depth);
		this.depth = depth;
	endfunction

endclass


`endif