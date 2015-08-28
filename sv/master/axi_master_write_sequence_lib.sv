
`ifndef AXI_MASTER_WRITE_SEQUENCE_LIB_SVH
`define AXI_MASTER_WRITE_SEQUENCE_LIB_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_base_seq
//
//------------------------------------------------------------------------------

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

//------------------------------------------------------------------------------
//
// SEQUENCE: uvc_name_transfer_seq
//
//------------------------------------------------------------------------------
class axi_master_write_sequence_lib_test1 extends axi_master_write_sequence_base;

	// Add local random fields and constraints here

	`uvm_object_utils(axi_master_write_sequence_lib_test1)

	// new - constructor
	function new(string name="axi_master_write_sequence_lib_test1");
		super.new(name);
	endfunction

	virtual task body();
//		`uvm_do_with(req,{req.data.size inside{[1 : 10]};})
		`uvm_do(req);
		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);
//		`uvm_do(req);

//		get_response(rsp);
	endtask

endclass : axi_master_write_sequence_lib_test1


`endif
