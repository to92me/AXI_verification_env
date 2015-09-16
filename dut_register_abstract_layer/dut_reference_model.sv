`ifndef DUT_REGISTER_MODEL_REFERECE_MODEL_SVH
`define DUT_REGISTER_MODEL_REFERECE_MODEL_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

typedef enum{
	RIS_e = 0,
	MIS_e = 1,
	LOAD_e = 2,
	CFG_e = 3,
	SWRESET_e = 4,
	IIR_e = 5,
	MATCH = 6,
	COUNT = 7
} reg_type_enum;


class dut_referece_model extends uvm_component;


	dut_register_block  dut_register_model;
	event clock;
	int clock_frek;


`uvm_component_utils_begin(dut_referece_model)
	 `uvm_field_int(RIS, UVM_DEFAULT)
	 `uvm_field_int(IM, UVM_DEFAULT)
	 `uvm_field_int(MIS, UVM_DEFAULT)
	 `uvm_field_int(LOAD, UVM_DEFAULT)
	 `uvm_field_int(CFG, UVM_DEFAULT)
	 `uvm_field_int(SWRESET, UVM_DEFAULT)
	 `uvm_field_int(IIR, UVM_DEFAULT)
	 `uvm_field_int(MATCH, UVM_DEFAULT)
	 `uvm_field_int(COUNT, UVM_DEFAULT)
 `uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern task main();
	extern task clockGenerator();
	extern task refereceModelMain();

endclass : dut_referece_model

	task dut_referece_model::main();
	    fork
		    this.clockGenerator();
		    this.refereceModelMain();
	    join
	endtask

	task dut_referece_model::clockGenerator();
		forever begin
		#clock_frek
		->clock;
		end
	endtask

	task dut_referece_model::refereceModelMain();
		forever begin
			@clock
			if(dut_register_model.CFG_reg.counter_enable == 1'b1 && dut_register_model.CFG_reg.direction == 1'b0)
				begin
					dut_register_model.COUNT_reg.counter++;
					if()
				end
			else if(dut_register_model.CFG_reg.counter_enable == 1'b1 && dut_register_model.CFG_reg.direction == 1'b1)
				begin
				end
		end
	endtask



`endif