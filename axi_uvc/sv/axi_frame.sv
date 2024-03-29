`ifndef AXI_FRAME_SVH
`define AXI_FRAME_SVH
//------------------------------------------------------------------------------
//
// CLASS: axi_frame
//
//------------------------------------------------------------------------------
class axi_frame_base extends uvm_sequence_item;

	//Declare fields
	rand bit [ADDR_WIDTH-1 : 0]		addr;
	rand bit [7:0]					len;
	rand burst_size_enum			size;
	rand burst_type_enum			burst_type;
	rand lock_enum					lock;
	rand bit [WID_WIDTH-1 : 0]		id;
	rand bit [3:0]					cache;
	rand bit [2:0]					prot;
	rand bit [3:0]					qos;
	rand bit [3:0]					region;
	rand bit [WUSER_WIDTH -1 : 0]	wuser;
	rand bit [AWUSER_WIDTH - 1 : 0]	awuser;
	rand response_enum				resp;

	// UVM utility macros
	`uvm_object_utils_begin(axi_frame_base)
	 `uvm_field_int(addr, UVM_DEFAULT)
	 `uvm_field_int(len, UVM_DEFAULT)
	 `uvm_field_enum(burst_size_enum, size, UVM_DEFAULT)
	 `uvm_field_enum(burst_type_enum, burst_type, UVM_DEFAULT)
	 `uvm_field_enum(lock_enum, lock, UVM_DEFAULT)
	 `uvm_field_int(id, UVM_DEFAULT)
	 `uvm_field_int(cache, UVM_DEFAULT)
	 `uvm_field_int(prot, UVM_DEFAULT)
	 `uvm_field_int(qos, UVM_DEFAULT)
	 `uvm_field_int(region, UVM_DEFAULT)
	 `uvm_field_int(wuser, UVM_DEFAULT)
	 `uvm_field_int(awuser, UVM_DEFAULT)
 `uvm_object_utils_end

	function new (string name = "axi_frame");
		super.new(name);
	endfunction

	constraint burst_size_constraint 	{size <= $clog2(DATA_WIDTH / 8);}
	constraint burst_type_constraint 	{burst_type inside{FIXED, INCR, WRAP};}
	constraint resp_constraint 			{resp inside {OKAY, EXOKAY, DECERR, SLVERR};}


endclass

class axi_frame extends axi_frame_base;

	//Declare fields
	rand bit[DATA_WIDTH-1 : 0]      data[$];

	// UVM utility macros
	`uvm_object_utils_begin(axi_frame)
	 `uvm_field_queue_int(data, UVM_DEFAULT)
 `   uvm_object_utils_end

 	constraint data_size_csr {
	 	data.size() == this.len + 1;
	}
	function new (string name = "axi_frame");
		super.new(name);
	endfunction

//	extern function copyQueue(input bit[DATA_WIDTH-1 : 0] input_data[$]);

endclass :  axi_frame


class axi_single_frame extends axi_frame_base;
		//Declare fields
	rand bit[DATA_WIDTH-1 : 0]      data;
	rand int 						delay;
	rand int						delay_addr;
	rand int 						delay_data;
//	rand int 						delay_awvalid;
//	rand int 						delay_wvalid;
	bit [STRB_WIDTH - 1 : 0]		strobe;
	true_false_enum 				last_one = FALSE;
	true_false_enum 				first_one = FALSE;

	// UVM utility macros
`uvm_object_utils_begin(axi_single_frame)
	 `uvm_field_int(data, UVM_DEFAULT)
	 `uvm_field_int(delay, UVM_DEFAULT)
	 `uvm_field_int(delay_addr, UVM_DEFAULT)
	 `uvm_field_int(delay_data, UVM_DEFAULT)
//	 `uvm_field_int(delay_awvalid, UVM_DEFAULT)
//	 `uvm_field_int(delay_wvalid, UVM_DEFAULT)
	 `uvm_field_enum(true_false_enum, last_one, UVM_DEFAULT)
	 `uvm_field_enum(true_false_enum, first_one, UVM_DEFAULT)
	 `uvm_field_enum(true_false_enum, first_one, UVM_DEFAULT)
 `uvm_object_utils_end

	constraint delay_cst{
		delay inside {[0 : 5]};
	}

	constraint delay_addrdata_csr{
		delay_data inside 	{[0 : 5]};
		delay_addr inside	{[0 : 5]};
	}

//	constraint delay_awvalid_csr{
//		delay_awvalid inside {[0 : 5]};
//	}

//	constraint delay_wvalid_csr{
//		delay_wvalid inside {[0:5]};
//	}

	function new (string name = "axi_frame");
		super.new(name);
	endfunction

endclass

`endif
