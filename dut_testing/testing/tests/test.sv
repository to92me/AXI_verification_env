`ifndef DUT_REGISTER_MODEL_TEST_SVH
`define DUT_REGISTER_MODEL_TEST_SVH

class dut_register_model_test_base extends uvm_test;

	dut_register_model_tb tb0;
	uvm_table_printer printer;
	dut_register_block						register_model;
	dut_register_model_test_sequence		register_model_test_seq;
	dut_tesgin_logger_test_sequence			register_model_logger_seq;

	`uvm_component_utils(dut_register_model_test_base)

	function new(string name = "dut_register_model_test_base", uvm_component parent);
		super.new(name,parent);
		$display("TOME");
		printer = new();
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		register_model	= dut_register_block::type_id::create("DutRegisterModelBlock", 	this);
		register_model.build();
		//register_model.

		set_config_int("*", "recording_detail", UVM_FULL);
		uvm_config_int::set(this, "tb0.*", "coverage_enable", 1);

		tb0 =  dut_register_model_tb::type_id::create("tb0",this);
		tb0.register_model = register_model;

		 uvm_config_int::set(this, "*", "master_ready_rand_enable", 0);

		register_model_test_seq = dut_register_model_test_sequence::type_id::create(.name("dut_register_model_test_sequence"),
																					.parent(this));
		register_model_test_seq.register_model = register_model;

		register_model_logger_seq = dut_tesgin_logger_test_sequence::type_id::create("register_model_logger_seq", this);
		register_model_logger_seq.register_model = register_model;


		set_config_string("*tb0.env.DutRegisterModelTopSequencer.run_phase", "default_sequence", "dut_register_model_test_sequence");

//		uvm_config_wrapper::set(this, "tb0.env.DutRegisterModelTopSequencer.run_phase",
//          "default_sequence", dut_register_model_test_sequence::get_type());

		uvm_config_wrapper::set(this, "tb0.env.DutRegisterModelLowSequencer.run_phase",
          "default_sequence", dut_register_model_lower_sequence::get_type());


		uvm_config_wrapper::set(this, "tb0.env.AxiWriteWrapperAgent.AxiWriteWrapperLowSequencer.run_phase",
          "default_sequence", axi_write_wrapper_sequence::get_type());

		uvm_config_wrapper::set(this, "tb0.env.AxiReadWrapperAgent.AxiReadWrapperLowSequencer.run_phase",
          "default_sequence", axi_read_wrapper_sequence::get_type());


	endfunction

	// run_phase
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		printer.knobs.depth = 5;
//		this.print(printer);
	endtask

	task main_phase(uvm_phase phase);
			phase.raise_objection(this);
			//register_model_test_seq.start(tb0.dut_test_env.top_sequencer);
			register_model_logger_seq.start(tb0.dut_test_env.top_sequencer);
			phase.drop_objection(this);
	endtask


	function void start_of_simulation_phase( uvm_phase phase );
      super.start_of_simulation_phase( phase );
//      uvm_top.print_topology();
   endfunction: start_of_simulation_phase

endclass



`endif