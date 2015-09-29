`ifndef DUT_REGISTER_MODEL_SEQUENCE_BASE_SVH
`define DUT_REGISTER_MODEL_SEQUENCE_BASE_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_base_seq
//
//------------------------------------------------------------------------------
class dut_register_model_base_sequence extends uvm_sequence #(dut_frame);

	// new - constructor
	function new(string name="dut_register_model_base_sequence");
		super.new(name);
	endfunction



	`uvm_object_utils(dut_register_model_base_sequence)
	`uvm_declare_p_sequencer(dut_register_model_top_sequencer)



	virtual task pre_body();
		$display("PRE BODY");

	if (starting_phase != null) begin
        starting_phase.raise_objection(this, {"Executing sequence '", get_full_name(), "'"});
//		uvm_test_done.set_drain_time(this, 200ns);
     end
     `uvm_info(get_full_name(), {"Executing sequence '",get_full_name(), "'"}, UVM_MEDIUM)
	endtask


	virtual task post_body();
		$display("POST BODY");

		 if (starting_phase != null) begin
        starting_phase.drop_objection(this, {"Completed sequence '",
                                             get_full_name(), "'"});

		uvm_test_done.set_drain_time(this, 200ns);
     end
	endtask


endclass : dut_register_model_base_sequence

//------------------------------------------------------------------------------
//
// SEQUENCE: uvc_name_transfer_seq
//
//------------------------------------------------------------------------------
class dut_register_model_test_sequence extends dut_register_model_base_sequence;

	dut_register_block		register_model;
	uvm_status_e			status;


	`uvm_object_utils(dut_register_model_test_sequence)

	// new - constructor
	function new(string name="dut_register_model_test_sequence");
		super.new(name);

	endfunction

	virtual task body();
//		$cast(register_model, model);
		int test_value;


//		super.body();
		$display("");
		$display("==============================================================================================================================================================");
		$display("=                                                             TEST_SEQ_1                                                                                     =");
		$display("==============================================================================================================================================================");
		$display("");

		register_model.IM_reg.write(status, 3'b111 );
//		register_model.IM_reg.match.write(status, 1'b1);
		register_model.MATCH_reg.write(status, 50);
		register_model.CFG_reg.write(status, 3 );
		test_value = 6000;


		#100000
		register_model.RIS_reg.mirror(status, UVM_CHECK);

//		register_model.COUNT_reg.mirror(status, UVM_CHECK);


		register_model.RIS_reg.underflow.mirror(status, UVM_CHECK);
		register_model.RIS_reg.overflow.mirror(status, UVM_CHECK);
		register_model.RIS_reg.match.mirror(status, UVM_CHECK);
//		register_model.MIS_reg.mirror(status, UVM_CHECK);



//		`uvm_do_with(req,{req.rw == AXI_WRITE; req.id == 0; req.len == 0; req.addr == 8; req.data[0] == 16'hffff; req.size == 1; req.burst_type == FIXED;} )
//		`uvm_do_with(req,{req.rw == AXI_WRITE; req.id == 0; req.len == 0; req.addr == 8; req.data[0] == 16'hffff; req.size == 1; req.burst_type == FIXED;} )
//		`uvm_do_with(req,{req.rw == AXI_WRITE; req.id == 0; req.len == 0; req.addr == 8; req.data[0] == 16'hffff; req.size == 1; req.burst_type == FIXED;} )
//		`uvm_do_with(req,{req.rw == AXI_WRITE; req.id == 0; req.len == 0; req.addr == 8; req.data[0] == 16'hffff; req.size == 1; req.burst_type == FIXED;} )

//		`uvm_do_with(req,{req.rw == AXI_WRITE; req.id == 0; req.len == 0; req.addr == 8; req.data[0] == 16'hffff;} )
//		`uvm_do_with(req,{req.rw == AXI_WRITE; req.id == 0; req.len == 0; req.addr == 8; req.data[0] == 16'hffff;} )
//		`uvm_do_with(req,{req.rw == AXI_WRITE; req.id == 0; req.len == 0; req.addr == 8; req.data[0] == 16'hffff;} )

		$display("");
		$display("==============================================================================================================================================================");
		$display("=                                                          END TEST_SEQ_1                                                                                    =");
		$display("==============================================================================================================================================================");
		$display("");



	endtask

endclass : dut_register_model_test_sequence


`endif
