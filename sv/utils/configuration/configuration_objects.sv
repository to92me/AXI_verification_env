`ifndef AXI_CONFIGURATION_OBJECTS_SVH_TOME
`define AXI_CONFIGURATION_OBJECTS_SVH_TOME

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


//------------------------------------------------------------------------------
//
// CLASS: AXI_CONFIGURATION_OBJECTS_SVH
//
//------------------------------------------------------------------------------

/*
class uvc_axi_write_conf extends uvm_object;


	true_false_enum			do_coverage								= TRUE;
	true_false_enum			do_checks 								= TRUE;

	int 			master_write_deepth 					= 5;

	//correct incorrect value
	int 			awid_mode 						= 1;
	int 			awregion_mode 					= 1;
	int 			awlen_mode						= 1;
	int 			awsize_mode 					= 1;
	int 			awburst_mode					= 1;
	int 			awlock_mode 					= 1;
	int 			awcache_mode					= 1;
	int 			awqos_mode 						= 1;
	int 			wstrb_mode 						= 1;
	int 			bresp_mode 						= 1;

	// MASTER
	// data
	true_false_enum			data_valid_delay 						= TRUE;
	true_false_enum			data_constant_delay 					= FALSE;
	int 					data_constant_delay_value 				= 2;
	int 					data_delay_minimum						= 0;
	int 					data_delay_maximum						= 5;

	//addr
	true_false_enum			addr_valid_delay 						= TRUE;
	true_false_enum			addr_constant_delay						= FALSE;
	int 					addr_constant_delay_value 				= 2;
	int 					addr_data_delay_minimum					= 0;
	int 					addr_delay_maximum						= 5;

	//main
	true_false_enum			data_before_addr 						= FALSE;

	//resp
	true_false_enum			bready_delay_constant					= FALSE;
	int						bready_delay_const_value				= 5;
	int 					bready_delay_minimum 					= 0;
	int 					bready_delay_maximum					= 5;

	true_false_enum			bready_constant							= FALSE;
	int 					bready_const_value						= 0;
	int 					bready_posibility_of_0					= 5;
	int 					bready_posibility_of_1					= 5;


    // SLAVE
    // data
	true_false_enum			wready_delay_constant					= FALSE;
	int						wready_delay_const_value				= 5;
	int 					wready_delay_minimum 					= 0;
	int 					wready_delay_maximum					= 5;

	true_false_enum			wready_constant							= FALSE;
	int 					wready_const_value						= 0;
	int 					wready_posibility_of_0					= 5;
	int 					wready_posibility_of_1					= 5;

	//addr
	true_false_enum			awready_delay_constant					= FALSE;
	int						awready_delay_const_value				= 5;
	int 					awready_delay_minimum 					= 0;
	int 					awready_delay_masimum					= 5;

	true_false_enum			awready_constant						= FALSE;
	int 					awready_const_value						= 0;
	int 					awready_posibility_of_0					= 5;
	int 					awready_posibility_of_1					= 5;

	//response
	true_false_enum			bvalid_valid_delay 						= FALSE;
	true_false_enum			bvalid_constant_delay 					= FALSE;
	int 					bvalid_constant_delay_value				= 2;
	int 					bvalid_data_delay_minimum				= 0;
	int 					bvalid_delay_maximum					= 5;

	// Get addr_constant_delay
	function true_false_enum getAddr_constant_delay();
		return addr_constant_delay;
	endfunction

	// Set addr_constant_delay
	function void setAddr_constant_delay(true_false_enum addr_constant_delay);
		this.addr_constant_delay = addr_constant_delay;
	endfunction

	// Get addr_constant_delay_value
	function int getAddr_constant_delay_value();
		return addr_constant_delay_value;
	endfunction

	// Set addr_constant_delay_value
	function void setAddr_constant_delay_value(int addr_constant_delay_value);
		this.addr_constant_delay_value = addr_constant_delay_value;
	endfunction

	// Get addr_data_delay_minimum
	function int getAddr_data_delay_minimum();
		return addr_data_delay_minimum;
	endfunction

	// Set addr_data_delay_minimum
	function void setAddr_data_delay_minimum(int addr_data_delay_minimum);
		this.addr_data_delay_minimum = addr_data_delay_minimum;
	endfunction

	// Get addr_delay_maximum
	function int getAddr_delay_maximum();
		return addr_delay_maximum;
	endfunction

	// Set addr_delay_maximum
	function void setAddr_delay_maximum(int addr_delay_maximum);
		this.addr_delay_maximum = addr_delay_maximum;
	endfunction

	// Get addr_valid_delay
	function true_false_enum getAddr_valid_delay();
		return addr_valid_delay;
	endfunction

	// Set addr_valid_delay
	function void setAddr_valid_delay(true_false_enum addr_valid_delay);
		this.addr_valid_delay = addr_valid_delay;
	endfunction

	// Get awburst_mode
	function int getAwburst_mode();
		return awburst_mode;
	endfunction

	// Set awburst_mode
	function void setAwburst_mode(int awburst_mode);
		this.awburst_mode = awburst_mode;
	endfunction

	// Get awcache_mode
	function int getAwcache_mode();
		return awcache_mode;
	endfunction

	// Set awcache_mode
	function void setAwcache_mode(int awcache_mode);
		this.awcache_mode = awcache_mode;
	endfunction

	// Get awid_mode
	function int getAwid_mode();
		return awid_mode;
	endfunction

	// Set awid_mode
	function void setAwid_mode(int awid_mode);
		this.awid_mode = awid_mode;
	endfunction

	// Get awlen_mode
	function int getAwlen_mode();
		return awlen_mode;
	endfunction

	// Set awlen_mode
	function void setAwlen_mode(int awlen_mode);
		this.awlen_mode = awlen_mode;
	endfunction

	// Get awlock_mode
	function int getAwlock_mode();
		return awlock_mode;
	endfunction

	// Set awlock_mode
	function void setAwlock_mode(int awlock_mode);
		this.awlock_mode = awlock_mode;
	endfunction

	// Get awqos_mode
	function int getAwqos_mode();
		return awqos_mode;
	endfunction

	// Set awqos_mode
	function void setAwqos_mode(int awqos_mode);
		this.awqos_mode = awqos_mode;
	endfunction

	// Get awready_const_value
	function int getAwready_const_value();
		return awready_const_value;
	endfunction

	// Set awready_const_value
	function void setAwready_const_value(int awready_const_value);
		this.awready_const_value = awready_const_value;
	endfunction

	// Get awready_constant
	function true_false_enum getAwready_constant();
		return awready_constant;
	endfunction

	// Set awready_constant
	function void setAwready_constant(true_false_enum awready_constant);
		this.awready_constant = awready_constant;
	endfunction

	// Get awready_delay_const_value
	function int getAwready_delay_const_value();
		return awready_delay_const_value;
	endfunction

	// Set awready_delay_const_value
	function void setAwready_delay_const_value(int awready_delay_const_value);
		this.awready_delay_const_value = awready_delay_const_value;
	endfunction

	// Get awready_delay_constant
	function true_false_enum getAwready_delay_constant();
		return awready_delay_constant;
	endfunction

	// Set awready_delay_constant
	function void setAwready_delay_constant(true_false_enum awready_delay_constant);
		this.awready_delay_constant = awready_delay_constant;
	endfunction

	// Get awready_delay_masimum
	function int getAwready_delay_masimum();
		return awready_delay_masimum;
	endfunction

	// Set awready_delay_masimum
	function void setAwready_delay_masimum(int awready_delay_masimum);
		this.awready_delay_masimum = awready_delay_masimum;
	endfunction

	// Get awready_delay_minimum
	function int getAwready_delay_minimum();
		return awready_delay_minimum;
	endfunction

	// Set awready_delay_minimum
	function void setAwready_delay_minimum(int awready_delay_minimum);
		this.awready_delay_minimum = awready_delay_minimum;
	endfunction

	// Get awready_posibility_of_0
	function int getAwready_posibility_of_0();
		return awready_posibility_of_0;
	endfunction

	// Set awready_posibility_of_0
	function void setAwready_posibility_of_0(int awready_posibility_of_0);
		this.awready_posibility_of_0 = awready_posibility_of_0;
	endfunction

	// Get awready_posibility_of_1
	function int getAwready_posibility_of_1();
		return awready_posibility_of_1;
	endfunction

	// Set awready_posibility_of_1
	function void setAwready_posibility_of_1(int awready_posibility_of_1);
		this.awready_posibility_of_1 = awready_posibility_of_1;
	endfunction

	// Get awregion_mode
	function int getAwregion_mode();
		return awregion_mode;
	endfunction

	// Set awregion_mode
	function void setAwregion_mode(int awregion_mode);
		this.awregion_mode = awregion_mode;
	endfunction

	// Get awsize_mode
	function int getAwsize_mode();
		return awsize_mode;
	endfunction

	// Set awsize_mode
	function void setAwsize_mode(int awsize_mode);
		this.awsize_mode = awsize_mode;
	endfunction

	// Get bready_const_value
	function int getBready_const_value();
		return bready_const_value;
	endfunction

	// Set bready_const_value
	function void setBready_const_value(int bready_const_value);
		this.bready_const_value = bready_const_value;
	endfunction

	// Get bready_constant
	function true_false_enum getBready_constant();
		return bready_constant;
	endfunction

	// Set bready_constant
	function void setBready_constant(true_false_enum bready_constant);
		this.bready_constant = bready_constant;
	endfunction

	// Get bready_delay_const_value
	function int getBready_delay_const_value();
		return bready_delay_const_value;
	endfunction

	// Set bready_delay_const_value
	function void setBready_delay_const_value(int bready_delay_const_value);
		this.bready_delay_const_value = bready_delay_const_value;
	endfunction

	// Get bready_delay_constant
	function true_false_enum getBready_delay_constant();
		return bready_delay_constant;
	endfunction

	// Set bready_delay_constant
	function void setBready_delay_constant(true_false_enum bready_delay_constant);
		this.bready_delay_constant = bready_delay_constant;
	endfunction

	// Get bready_delay_maximum
	function int getBready_delay_maximum();
		return bready_delay_maximum;
	endfunction

	// Set bready_delay_maximum
	function void setBready_delay_maximum(int bready_delay_maximum);
		this.bready_delay_maximum = bready_delay_maximum;
	endfunction

	// Get bready_delay_minimum
	function int getBready_delay_minimum();
		return bready_delay_minimum;
	endfunction

	// Set bready_delay_minimum
	function void setBready_delay_minimum(int bready_delay_minimum);
		this.bready_delay_minimum = bready_delay_minimum;
	endfunction

	// Get bready_posibility_of_0
	function int getBready_posibility_of_0();
		return bready_posibility_of_0;
	endfunction

	// Set bready_posibility_of_0
	function void setBready_posibility_of_0(int bready_posibility_of_0);
		this.bready_posibility_of_0 = bready_posibility_of_0;
	endfunction

	// Get bready_posibility_of_1
	function int getBready_posibility_of_1();
		return bready_posibility_of_1;
	endfunction

	// Set bready_posibility_of_1
	function void setBready_posibility_of_1(int bready_posibility_of_1);
		this.bready_posibility_of_1 = bready_posibility_of_1;
	endfunction

	// Get bresp_mode
	function int getBresp_mode();
		return bresp_mode;
	endfunction

	// Set bresp_mode
	function void setBresp_mode(int bresp_mode);
		this.bresp_mode = bresp_mode;
	endfunction

	// Get bvalid_constant_delay
	function true_false_enum getBvalid_constant_delay();
		return bvalid_constant_delay;
	endfunction

	// Set bvalid_constant_delay
	function void setBvalid_constant_delay(true_false_enum bvalid_constant_delay);
		this.bvalid_constant_delay = bvalid_constant_delay;
	endfunction

	// Get bvalid_constant_delay_value
	function int getBvalid_constant_delay_value();
		return bvalid_constant_delay_value;
	endfunction

	// Set bvalid_constant_delay_value
	function void setBvalid_constant_delay_value(int bvalid_constant_delay_value);
		this.bvalid_constant_delay_value = bvalid_constant_delay_value;
	endfunction

	// Get bvalid_data_delay_minimum
	function int getBvalid_data_delay_minimum();
		return bvalid_data_delay_minimum;
	endfunction

	// Set bvalid_data_delay_minimum
	function void setBvalid_data_delay_minimum(int bvalid_data_delay_minimum);
		this.bvalid_data_delay_minimum = bvalid_data_delay_minimum;
	endfunction

	// Get bvalid_delay_maximum
	function int getBvalid_delay_maximum();
		return bvalid_delay_maximum;
	endfunction

	// Set bvalid_delay_maximum
	function void setBvalid_delay_maximum(int bvalid_delay_maximum);
		this.bvalid_delay_maximum = bvalid_delay_maximum;
	endfunction

	// Get bvalid_valid_delay
	function true_false_enum getBvalid_valid_delay();
		return bvalid_valid_delay;
	endfunction

	// Set bvalid_valid_delay
	function void setBvalid_valid_delay(true_false_enum bvalid_valid_delay);
		this.bvalid_valid_delay = bvalid_valid_delay;
	endfunction

	// Get data_before_addr
	function true_false_enum getData_before_addr();
		return data_before_addr;
	endfunction

	// Set data_before_addr
	function void setData_before_addr(true_false_enum data_before_addr);
		this.data_before_addr = data_before_addr;
	endfunction

	// Get data_constant_delay
	function true_false_enum getData_constant_delay();
		return data_constant_delay;
	endfunction

	// Set data_constant_delay
	function void setData_constant_delay(true_false_enum data_constant_delay);
		this.data_constant_delay = data_constant_delay;
	endfunction

	// Get data_constant_delay_value
	function int getData_constant_delay_value();
		return data_constant_delay_value;
	endfunction

	// Set data_constant_delay_value
	function void setData_constant_delay_value(int data_constant_delay_value);
		this.data_constant_delay_value = data_constant_delay_value;
	endfunction

	// Get data_delay_maximum
	function int getData_delay_maximum();
		return data_delay_maximum;
	endfunction

	// Set data_delay_maximum
	function void setData_delay_maximum(int data_delay_maximum);
		this.data_delay_maximum = data_delay_maximum;
	endfunction

	// Get data_delay_minimum
	function int getData_delay_minimum();
		return data_delay_minimum;
	endfunction

	// Set data_delay_minimum
	function void setData_delay_minimum(int data_delay_minimum);
		this.data_delay_minimum = data_delay_minimum;
	endfunction

	// Get data_valid_delay
	function true_false_enum getData_valid_delay();
		return data_valid_delay;
	endfunction

	// Set data_valid_delay
	function void setData_valid_delay(true_false_enum data_valid_delay);
		this.data_valid_delay = data_valid_delay;
	endfunction

	// Get do_checks
	function true_false_enum getDo_checks();
		return do_checks;
	endfunction

	// Set do_checks
	function void setDo_checks(true_false_enum do_checks);
		this.do_checks = do_checks;
	endfunction

	// Get do_coverage
	function true_false_enum getDo_coverage();
		return do_coverage;
	endfunction

	// Set do_coverage
	function void setDo_coverage(true_false_enum do_coverage);
		this.do_coverage = do_coverage;
	endfunction

	// Get master_write_deepth
	function int getMaster_write_deepth();
		return master_write_deepth;
	endfunction

	// Set master_write_deepth
	function void setMaster_write_deepth(int master_write_deepth);
		this.master_write_deepth = master_write_deepth;
	endfunction

	// Get wready_const_value
	function int getWready_const_value();
		return wready_const_value;
	endfunction

	// Set wready_const_value
	function void setWready_const_value(int wready_const_value);
		this.wready_const_value = wready_const_value;
	endfunction

	// Get wready_constant
	function true_false_enum getWready_constant();
		return wready_constant;
	endfunction

	// Set wready_constant
	function void setWready_constant(true_false_enum wready_constant);
		this.wready_constant = wready_constant;
	endfunction

	// Get wready_delay_const_value
	function int getWready_delay_const_value();
		return wready_delay_const_value;
	endfunction

	// Set wready_delay_const_value
	function void setWready_delay_const_value(int wready_delay_const_value);
		this.wready_delay_const_value = wready_delay_const_value;
	endfunction

	// Get wready_delay_constant
	function true_false_enum getWready_delay_constant();
		return wready_delay_constant;
	endfunction

	// Set wready_delay_constant
	function void setWready_delay_constant(true_false_enum wready_delay_constant);
		this.wready_delay_constant = wready_delay_constant;
	endfunction

	// Get wready_delay_maximum
	function int getWready_delay_maximum();
		return wready_delay_maximum;
	endfunction

	// Set wready_delay_maximum
	function void setWready_delay_maximum(int wready_delay_maximum);
		this.wready_delay_maximum = wready_delay_maximum;
	endfunction

	// Get wready_delay_minimum
	function int getWready_delay_minimum();
		return wready_delay_minimum;
	endfunction

	// Set wready_delay_minimum
	function void setWready_delay_minimum(int wready_delay_minimum);
		this.wready_delay_minimum = wready_delay_minimum;
	endfunction

	// Get wready_posibility_of_0
	function int getWready_posibility_of_0();
		return wready_posibility_of_0;
	endfunction

	// Set wready_posibility_of_0
	function void setWready_posibility_of_0(int wready_posibility_of_0);
		this.wready_posibility_of_0 = wready_posibility_of_0;
	endfunction

	// Get wready_posibility_of_1
	function int getWready_posibility_of_1();
		return wready_posibility_of_1;
	endfunction

	// Set wready_posibility_of_1
	function void setWready_posibility_of_1(int wready_posibility_of_1);
		this.wready_posibility_of_1 = wready_posibility_of_1;
	endfunction

	// Get wstrb_mode
	function int getWstrb_mode();
		return wstrb_mode;
	endfunction

	// Set wstrb_mode
	function void setWstrb_mode(int wstrb_mode);
		this.wstrb_mode = wstrb_mode;
	endfunction



endclass
*/
//------------------------------------------------------------------------------
//
// CLASS: AXI_CONFIGURATION_OBJECTS_SVH
//
//------------------------------------------------------------------------------

class axi_write_buss_write_configuration extends uvm_object;

	true_false_enum			valid_delay_exists						= TRUE;
	true_false_enum			valid_constant_delay					= FALSE;
	int 					valid_contant_delay_value 				= 2;
	int 					valid_delay_minimum						= 0;
	int 					valid_delay_maximum						= 5;



 `uvm_object_utils_begin(axi_write_buss_write_configuration)
	 `uvm_field_enum(true_false_enum, valid_delay_exists, UVM_DEFAULT)
	 `uvm_field_enum(true_false_enum, valid_constant_delay, UVM_DEFAULT)
	 `uvm_field_int(valid_contant_delay_value, UVM_DEFAULT)
	 `uvm_field_int(valid_delay_minimum, UVM_DEFAULT)
	 `uvm_field_int(valid_delay_maximum, UVM_DEFAULT)
 `uvm_object_utils_end



	function new(string name = "axi_write_buss_write_configuration");
		super.new(name);
	endfunction: new

	// Get delay_maximum
	function int getDelay_maximum();
		return valid_delay_maximum;
	endfunction

	// Set delay_maximum
	function void setDelay_maximum(int delay_maximum);
		this.valid_delay_maximum = delay_maximum;
	endfunction

	// Get delay_minimum
	function int getDelay_minimum();
		return valid_delay_minimum;
	endfunction

	// Set delay_minimum
	function void setDelay_minimum(int delay_minimum);
		this.valid_delay_minimum = delay_minimum;
	endfunction


	// Get valid_constant_delay
	function true_false_enum getValid_constant_delay();
		return valid_constant_delay;
	endfunction

	// Set valid_constant_delay
	function void setValid_constant_delay(true_false_enum valid_constant_delay);
		this.valid_constant_delay = valid_constant_delay;
	endfunction

	// Get valid_contant_delay_value
	function int getValid_contant_delay_value();
		return valid_contant_delay_value;
	endfunction

	// Set valid_contant_delay_value
	function void setValid_contant_delay_value(int valid_contant_delay_value);
		this.valid_contant_delay_value = valid_contant_delay_value;
	endfunction

	// Get valid_delay
	function true_false_enum getValid_delay_exists();
		return valid_delay_exists;
	endfunction

	// Set valid_delay
	function void setValid_delay_exists(true_false_enum valid_delay);
		this.valid_delay_exists = valid_delay;
	endfunction

endclass


class axi_write_buss_read_configuration extends uvm_object;

	true_false_enum			ready_delay_exists						= TRUE;
	true_false_enum			ready_delay_constant					= FALSE;
	int						ready_delay_const_value					= 5;
	int 					ready_delay_minimum 					= 0;
	int 					ready_delay_maximum						= 5;
	true_false_enum			ready_constant							= FALSE;
	int 					ready_const_value						= 0;
	int 					ready_posibility_of_0					= 5;
	int 					ready_posibility_of_1					= 5;


 `uvm_object_utils_begin(axi_write_buss_read_configuration)
	 `uvm_field_enum(true_false_enum, ready_delay_exists, UVM_DEFAULT)
	 `uvm_field_enum(true_false_enum, ready_delay_constant, UVM_DEFAULT)
	 `uvm_field_int(ready_delay_const_value, UVM_DEFAULT)
	 `uvm_field_int(ready_delay_minimum, UVM_DEFAULT)
	 `uvm_field_int(ready_delay_maximum, UVM_DEFAULT)
	 `uvm_field_enum(true_false_enum, ready_constant, UVM_DEFAULT)
	 `uvm_field_int(ready_const_value, UVM_DEFAULT)
	 `uvm_field_int(ready_posibility_of_0, UVM_DEFAULT)
	 `uvm_field_int(ready_posibility_of_1, UVM_DEFAULT)
 `uvm_object_utils_end



	function new(string name = "axi_write_buss_read_configuration");
		super.new(name);
	endfunction: new


	// Get ready_const_value
	function int getReady_const_value();
		return ready_const_value;
	endfunction

	// Set ready_const_value
	function void setReady_const_value(int ready_const_value);
		this.ready_const_value = ready_const_value;
	endfunction

	// Get ready_constant
	function true_false_enum getReady_constant();
		return ready_constant;
	endfunction

	// Set ready_constant
	function void setReady_constant(true_false_enum ready_constant);
		this.ready_constant = ready_constant;
	endfunction

	// Get ready_delay_const_value
	function int getReady_delay_const_value();
		return ready_delay_const_value;
	endfunction

	// Set ready_delay_const_value
	function void setReady_delay_const_value(int ready_delay_const_value);
		this.ready_delay_const_value = ready_delay_const_value;
	endfunction

	// Get ready_delay_constant
	function true_false_enum getReady_delay_constant();
		return ready_delay_constant;
	endfunction

	// Set ready_delay_constant
	function void setReady_delay_constant(true_false_enum ready_delay_constant);
		this.ready_delay_constant = ready_delay_constant;
	endfunction

	// Get ready_delay_exists
	function true_false_enum getReady_delay_exists();
		return ready_delay_exists;
	endfunction

	// Set ready_delay_exists
	function void setReady_delay_exists(true_false_enum ready_delay_exists);
		this.ready_delay_exists = ready_delay_exists;
	endfunction

	// Get ready_delay_maximum
	function int getReady_delay_maximum();
		return ready_delay_maximum;
	endfunction

	// Set ready_delay_maximum
	function void setReady_delay_maximum(int ready_delay_maximum);
		this.ready_delay_maximum = ready_delay_maximum;
	endfunction

	// Get ready_delay_minimum
	function int getReady_delay_minimum();
		return ready_delay_minimum;
	endfunction

	// Set ready_delay_minimum
	function void setReady_delay_minimum(int ready_delay_minimum);
		this.ready_delay_minimum = ready_delay_minimum;
	endfunction

	// Get ready_posibility_of_0
	function int getReady_posibility_of_0();
		return ready_posibility_of_0;
	endfunction

	// Set ready_posibility_of_0
	function void setReady_posibility_of_0(int ready_posibility_of_0);
		this.ready_posibility_of_0 = ready_posibility_of_0;
	endfunction

	// Get ready_posibility_of_1
	function int getReady_posibility_of_1();
		return ready_posibility_of_1;
	endfunction

	// Set ready_posibility_of_1
	function void setReady_posibility_of_1(int ready_posibility_of_1);
		this.ready_posibility_of_1 = ready_posibility_of_1;
	endfunction

endclass
//------------------------------------------------------------------------------
//
// CLASS: AXI_CONFIGURATION_OBJECTS_SVH
//
//------------------------------------------------------------------------------

class axi_write_correct_one_value extends uvm_object;
	int 	mode 			= 1;
	int 	dist_correct 	= 9;
	int 	dist_incorrect 	= 1;


 `uvm_object_utils_begin(axi_write_correct_one_value)
	 `uvm_field_int(mode, UVM_DEFAULT)
	 `uvm_field_int(dist_correct, UVM_DEFAULT)
	 `uvm_field_int(dist_incorrect, UVM_DEFAULT)
 `uvm_object_utils_end



	function new(string name = "axi_write_correct_one_value");
		super.new(name);
	endfunction: new

	// Get dist_correct
	function int getDist_correct();
		return dist_correct;
	endfunction

	// Set dist_correct
	function void setDist_correct(int dist_correct);
		this.dist_correct = dist_correct;
	endfunction

	// Get dist_incorrect
	function int getDist_incorrect();
		return dist_incorrect;
	endfunction

	// Set dist_incorrect
	function void setDist_incorrect(int dist_incorrect);
		this.dist_incorrect = dist_incorrect;
	endfunction

	// Get mode
	function int getMode();
		return mode;
	endfunction

	// Set mode
	function void setMode(int mode);
		this.mode = mode;
	endfunction


endclass

//------------------------------------------------------------------------------
//
// CLASS: AXI_CONFIGURATION_OBJECTS_SVH
//
//------------------------------------------------------------------------------


class axi_write_correct_value_conf extends uvm_object;
	axi_write_correct_one_value 		awid_conf;
	axi_write_correct_one_value			awregion_conf;
	axi_write_correct_one_value			awlen_conf;
	axi_write_correct_one_value			awsize_conf;
	axi_write_correct_one_value			awburst_conf;
	axi_write_correct_one_value			awlock_conf;
	axi_write_correct_one_value			awcache_conf;
	axi_write_correct_one_value			awqos_conf;
	axi_write_correct_one_value			wstrb_conf;
	axi_write_correct_one_value			bresp_conf;


 `uvm_object_utils_begin(axi_write_correct_value_conf)
	 `uvm_field_object(awid_conf, UVM_DEFAULT)
	 `uvm_field_object(awregion_conf, UVM_DEFAULT)
	 `uvm_field_object(awlen_conf, UVM_DEFAULT)
	 `uvm_field_object(awsize_conf, UVM_DEFAULT)
	 `uvm_field_object(awburst_conf, UVM_DEFAULT)
	 `uvm_field_object(awlock_conf, UVM_DEFAULT)
	 `uvm_field_object(awcache_conf, UVM_DEFAULT)
	 `uvm_field_object(awqos_conf, UVM_DEFAULT)
	 `uvm_field_object(wstrb_conf, UVM_DEFAULT)
	 `uvm_field_object(bresp_conf, UVM_DEFAULT)
 `uvm_object_utils_end



	function new(string name = "axi_write_correct_value_conf");
		super.new(name);
	endfunction: new

	// Get awburst_conf
	function axi_write_correct_one_value getAwburst_conf();
		return awburst_conf;
	endfunction

	// Set awburst_conf
	function void setAwburst_conf(axi_write_correct_one_value awburst_conf);
		this.awburst_conf = awburst_conf;
	endfunction

	// Get awcache_conf
	function axi_write_correct_one_value getAwcache_conf();
		return awcache_conf;
	endfunction

	// Set awcache_conf
	function void setAwcache_conf(axi_write_correct_one_value awcache_conf);
		this.awcache_conf = awcache_conf;
	endfunction

	// Get awid_conf
	function axi_write_correct_one_value getAwid_conf();
		return awid_conf;
	endfunction

	// Set awid_conf
	function void setAwid_conf(axi_write_correct_one_value awid_conf);
		this.awid_conf = awid_conf;
	endfunction

	// Get awlen_conf
	function axi_write_correct_one_value getAwlen_conf();
		return awlen_conf;
	endfunction

	// Set awlen_conf
	function void setAwlen_conf(axi_write_correct_one_value awlen_conf);
		this.awlen_conf = awlen_conf;
	endfunction

	// Get awlock_conf
	function axi_write_correct_one_value getAwlock_conf();
		return awlock_conf;
	endfunction

	// Set awlock_conf
	function void setAwlock_conf(axi_write_correct_one_value awlock_conf);
		this.awlock_conf = awlock_conf;
	endfunction

	// Get awqos
	function axi_write_correct_one_value getAwqos_conf();
		return awqos_conf;
	endfunction

	// Set awqos
	function void setAwqos_conf(axi_write_correct_one_value awqos_conf);
		this.awqos_conf = awqos_conf;
	endfunction

	// Get awregion_conf
	function axi_write_correct_one_value getAwregion_conf();
		return awregion_conf;
	endfunction

	// Set awregion_conf
	function void setAwregion_conf(axi_write_correct_one_value awregion_conf);
		this.awregion_conf = awregion_conf;
	endfunction

	// Get awsize_conf
	function axi_write_correct_one_value getAwsize_conf();
		return awsize_conf;
	endfunction

	// Set awsize_conf
	function void setAwsize_conf(axi_write_correct_one_value awsize_conf);
		this.awsize_conf = awsize_conf;
	endfunction

	// Get bresp
	function axi_write_correct_one_value getBresp_conf();
		return bresp_conf;
	endfunction

	// Set bresp
	function void setBresp_conf(axi_write_correct_one_value bresp_conf);
		this.bresp_conf = bresp_conf;
	endfunction

	// Get wstrb
	function axi_write_correct_one_value getWstrb_conf();
		return wstrb_conf;
	endfunction

	// Set wstrb
	function void setWstrb_conf(axi_write_correct_one_value wstrb_conf);
		this.wstrb_conf = wstrb_conf;
	endfunction

endclass


class axi_write_global_conf extends uvm_object;
	true_false_enum			do_coverage								= TRUE;
	true_false_enum			do_checks 								= TRUE;
	true_false_enum			correct_driving_vif 					= TRUE;
	true_false_enum			axi_3_support							= TRUE;
	int 					master_write_deepth 					= 5;
	true_false_enum 		delay_betwen_burst_packages				= TRUE;


 `uvm_object_utils_begin(axi_write_global_conf)
	 `uvm_field_enum(true_false_enum, do_coverage, UVM_DEFAULT)
	 `uvm_field_enum(true_false_enum, do_checks, UVM_DEFAULT)
	 `uvm_field_enum(true_false_enum, correct_driving_vif, UVM_DEFAULT)
	 `uvm_field_enum(true_false_enum, axi_3_support, UVM_DEFAULT)
	 `uvm_field_int(master_write_deepth, UVM_DEFAULT)
	 `uvm_field_enum(true_false_enum, delay_betwen_burst_packages, UVM_DEFAULT)
 `uvm_object_utils_end




	function new(string name = "axi_write_global_conf");
		super.new(name);
	endfunction: new


	// Get axi_3_support
	function true_false_enum getAxi_3_support();
		return axi_3_support;
	endfunction

	// Set axi_3_support
	function void setAxi_3_support(true_false_enum axi_3_support);
		this.axi_3_support = axi_3_support;
	endfunction

	// Get correct_driving_vif
	function true_false_enum getCorrect_driving_vif();
		return correct_driving_vif;
	endfunction

	// Set correct_driving_vif
	function void setCorrect_driving_vif(true_false_enum correct_driving_vif);
		this.correct_driving_vif = correct_driving_vif;
	endfunction

	// Get do_checks
	function true_false_enum getDo_checks();
		return do_checks;
	endfunction

	// Set do_checks
	function void setDo_checks(true_false_enum do_checks);
		this.do_checks = do_checks;
	endfunction

	// Get master_write_deepth
	function int getMaster_write_deepth();
		return master_write_deepth;
	endfunction

	// Set master_write_deepth
	function void setMaster_write_deepth(int master_write_deepth);
		this.master_write_deepth = master_write_deepth;
	endfunction

	// Get do_coverage
	function true_false_enum getDo_coverage();
		return do_coverage;
	endfunction

	// Set do_coverage
	function void setDo_coverage(true_false_enum do_coverage);
		this.do_coverage = do_coverage;
	endfunction

	function void setDelay_betwen_burst_packages(input true_false_enum delay_betwen_burst_packages);
		this.delay_betwen_burst_packages = delay_betwen_burst_packages;
	endfunction

	function true_false_enum getDelay_betwen_burst_packages();
		return this.delay_betwen_burst_packages;
	endfunction


endclass

class axi_write_conf extends uvm_object;



	axi_write_global_conf					global_config_object;
	axi_write_correct_value_conf			correct_value_config_object;

	axi_write_buss_write_configuration		master_data_config_object;
	axi_write_buss_write_configuration		master_addr_config_object;
	axi_write_buss_read_configuration		master_resp_config_object;

	axi_write_buss_read_configuration		slave_data_config_object;
	axi_write_buss_read_configuration		slave_addr_config_object;
 	axi_write_buss_write_configuration		slave_resp_config_object;


 `uvm_object_utils_begin(axi_write_conf)
	 `uvm_field_object(global_config_object, UVM_DEFAULT)
	 `uvm_field_object(correct_value_config_object, UVM_DEFAULT)
	 `uvm_field_object(master_data_config_object, UVM_DEFAULT)
	 `uvm_field_object(master_addr_config_object, UVM_DEFAULT)
	 `uvm_field_object(master_resp_config_object, UVM_DEFAULT)
	 `uvm_field_object(slave_data_config_object, UVM_DEFAULT)
	 `uvm_field_object(slave_addr_config_object, UVM_DEFAULT)
	 `uvm_field_object(slave_resp_config_object, UVM_DEFAULT)
 `uvm_object_utils_end




	function new(string name = "axi_write_conf");
		super.new(name);
	endfunction: new

	// Get correct_value_config_object
	function axi_write_correct_value_conf getCorrect_value_config_object();
		return correct_value_config_object;
	endfunction

	// Set correct_value_config_object
	function void setCorrect_value_config_object(axi_write_correct_value_conf correct_value_config_object);
		this.correct_value_config_object = correct_value_config_object;
	endfunction

	// Get global_config_object
	function axi_write_global_conf getGlobal_config_object();
		return global_config_object;
	endfunction

	// Set global_config_object
	function void setGlobal_config_object(axi_write_global_conf global_config_object);
		this.global_config_object = global_config_object;
	endfunction

	// Get master_addr_config_object
	function axi_write_buss_write_configuration getMaster_addr_config_object();
		return master_addr_config_object;
	endfunction

	// Set master_addr_config_object
	function void setMaster_addr_config_object(axi_write_buss_write_configuration master_addr_config_object);
		this.master_addr_config_object = master_addr_config_object;
	endfunction

	// Get master_data_config_object
	function axi_write_buss_write_configuration getMaster_data_config_object();
		return master_data_config_object;
	endfunction

	// Set master_data_config_object
	function void setMaster_data_config_object(axi_write_buss_write_configuration master_data_config_object);
		this.master_data_config_object = master_data_config_object;
	endfunction

	// Get master_resp_config_object
	function axi_write_buss_read_configuration getMaster_resp_config_object();
		return master_resp_config_object;
	endfunction

	// Set master_resp_config_object
	function void setMaster_resp_config_object(axi_write_buss_read_configuration master_resp_config_object);
		this.master_resp_config_object = master_resp_config_object;
	endfunction

	// Get slave_addr_config_object
	function axi_write_buss_read_configuration getSlave_addr_config_object();
		return slave_addr_config_object;
	endfunction

	// Set slave_addr_config_object
	function void setSlave_addr_config_object(axi_write_buss_read_configuration slave_addr_config_object);
		this.slave_addr_config_object = slave_addr_config_object;
	endfunction

	// Get slave_data_config_object
	function axi_write_buss_read_configuration getSlave_data_config_object();
		return slave_data_config_object;
	endfunction

	// Set slave_data_config_object
	function void setSlave_data_config_object(axi_write_buss_read_configuration slave_data_config_object);
		this.slave_data_config_object = slave_data_config_object;
	endfunction

	// Get slave_resp_config_object
	function axi_write_buss_write_configuration getSlave_resp_config_object();
		return slave_resp_config_object;
	endfunction

	// Set slave_resp_config_object
	function void setSlave_resp_config_object(axi_write_buss_write_configuration slave_resp_config_object);
		this.slave_resp_config_object = slave_resp_config_object;
	endfunction

	extern function void checkConfigs();

endclass

	function void axi_write_conf::checkConfigs();
		if(global_config_object == null)
			begin
				axi_write_global_conf default_global_conf;
				default_global_conf = new();
				this.setGlobal_config_object(default_global_conf);
				`uvm_info(get_name(), "Global conf is not seted creating default", UVM_HIGH);
			end

		if(correct_value_config_object == null)
			begin
				axi_write_correct_value_conf default_correct_value_conf;
				default_correct_value_conf = new();
				this.setCorrect_value_config_object(default_correct_value_conf);
				`uvm_info(get_name(), "Correct value conf is not set Creating dafault", UVM_HIGH);
			end

		if(master_data_config_object == null)
			begin
				axi_write_buss_write_configuration  default_bus_write_conf;
				default_bus_write_conf = new();
				this.setMaster_data_config_object(default_bus_write_conf);
				`uvm_info(get_name(), "Master Data conf is not set Creating dafault", UVM_HIGH);
			end

		if(master_addr_config_object == null)
			begin
				axi_write_buss_write_configuration  default_bus_write_conf;
				default_bus_write_conf = new();
				this.setMaster_addr_config_object(default_bus_write_conf);
				`uvm_info(get_name(), "Master addr conf is not set Creating dafault", UVM_HIGH);
			end

		if(master_resp_config_object == null)
			begin

				axi_write_buss_read_configuration default_bus_read_conf;
				default_bus_read_conf = new();
				this.setMaster_resp_config_object(default_bus_read_conf);
				`uvm_info(get_name(), "Master resp conf is not set Creating dafault", UVM_HIGH);
			end

		if(slave_data_config_object == null)
			begin
				axi_write_buss_read_configuration default_bus_read_conf;
				default_bus_read_conf = new();
				this.setSlave_addr_config_object(default_bus_read_conf);
				`uvm_info(get_name(), "Slave data conf is not set Creating dafault", UVM_HIGH);
			end

		if(slave_addr_config_object == null)
			begin
				axi_write_buss_read_configuration default_bus_read_conf;
				default_bus_read_conf = new();
				this.setSlave_addr_config_object(default_bus_read_conf);
				`uvm_info(get_name(), "Slave addr conf is not set Creating dafault", UVM_HIGH);

			end

		if(slave_resp_config_object == null)
			begin
				axi_write_buss_write_configuration  default_bus_write_conf;
				default_bus_write_conf = new();
				this.setSlave_resp_config_object(default_bus_write_conf);
				`uvm_info(get_name(), "Slave resp conf is not set Creating dafault", UVM_HIGH);
			end

	endfunction

`endif


