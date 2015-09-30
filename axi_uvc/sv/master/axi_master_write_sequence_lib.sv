
`ifndef AXI_MASTER_WRITE_SEQUENCE_LIB_SVH
`define AXI_MASTER_WRITE_SEQUENCE_LIB_SVH


/**
* Project : AXI UVC
*
* File : axi_master_write_sequence_base.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Tomislav Tumbas
*
* E-Mail : tomislav.tumbas@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : axi_master_write_sequence_base
*
* Classes :	1. axi_master_write_sequence_base
*
**/



//--------------------------------------------------------------------------------------
//
// CLASS: axi_master_write_sequence_base
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//		-UVM_SEQUENCE_LIB class ( for more information see uvm_cookbook )
//		-
//--------------------------------------------------------------------------------------

 class axi_master_write_sequence_base extends uvm_sequence #(axi_frame);


	// new - constructor
	function new(string name="axi_master_write_sequence_base");
		super.new(name);
	endfunction

	`uvm_object_utils(axi_master_write_sequence_base)
	`uvm_declare_p_sequencer(axi_master_write_sequencer)


	virtual task pre_body();
	if (starting_phase != null) begin
        starting_phase.raise_objection(this, {"Executing sequence '", get_full_name(), "'"});
		uvm_test_done.set_drain_time(this, 200ns);
     end
     `uvm_info(get_full_name(), {"Executing sequence '",get_full_name(), "'"}, UVM_MEDIUM)
	endtask


	virtual task post_body();

		 if (starting_phase != null) begin
        starting_phase.drop_objection(this, {"Completed sequence '",
                                             get_full_name(), "'"});

     end
	endtask

endclass : axi_master_write_sequence_base

//--------------------------------------------------------------------------------------
//
// CLASS: axi_master_write_sequence_lib_test1
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//		-UVM_SEQUENCE_LIB class ( for more information see uvm_cookbook )
//		-
//--------------------------------------------------------------------------------------

class axi_master_write_sequence_lib_test1 extends axi_master_write_sequence_base;

	// Add local random fields and constraints here
	int send_bursts = 20;

	`uvm_object_utils(axi_master_write_sequence_lib_test1)

	// new - constructor
	function new(string name="axi_master_write_sequence_lib_test1");
		super.new(name);
	endfunction

	extern function void response_handler(input uvm_sequence_item response);

	virtual task body();
		$display("7897897987987978798798798798798798798798798a7s98d7fa98s7d98f7as98d7f98as7d98f7a98sd7f98as7d89f7a9s8d7f98as7d98f7a9s8d7f98sa7d98fsa7d98f7as98d7f98asd7f98as7d98f");

		use_response_handler(1);

		repeat(send_bursts)
			begin

				`uvm_do (req)
			end

		wait(!send_bursts);

//		get_response(rsp);
	endtask

endclass : axi_master_write_sequence_lib_test1


function void axi_master_write_sequence_lib_test1::response_handler(input uvm_sequence_item response);
	    send_bursts--;
endfunction


// DODATO - ANDREA
////////////////////////////////////
class axi_master_write_dut_counter_seq extends axi_master_write_sequence_base;

	// Add local random fields and constraints here
	rand int count;
	rand int address;
	rand bit[15:0] write_data;

	`uvm_object_utils(axi_master_write_dut_counter_seq)

	// new - constructor
	function new(string name="axi_master_write_dut_counter_seq");
		super.new(name);
	endfunction

	extern function void response_handler(input uvm_sequence_item response);

	virtual task body();

		use_response_handler(1);

		repeat(count)
			begin
				`uvm_do_with(req, {req.burst_type == FIXED; req.size == 1; req.len == 0; req.addr == address; req.id == 0; req.data[0] == write_data;});
			end

		wait(!count);

//		get_response(rsp);
	endtask

endclass : axi_master_write_dut_counter_seq


function void axi_master_write_dut_counter_seq::response_handler(input uvm_sequence_item response);
	    count--;
endfunction
///////////////////////////////

`endif
