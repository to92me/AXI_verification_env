

`ifndef DUT_REFERECE_MODEL_SV
`define DUT_REFERECE_MODEL_SV

parameter TOLERANCE = 25;

//------------------------------------------------------------------------------
//
// CLASS: dut_reference_model
//
//------------------------------------------------------------------------------
/**
* Project : DUT_ register model
*
* File : reference_model.sv
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
* Description : dut reference model
*
* Classes :	1. dut_reference_model
*
**/

//-------------------------------------------------------------------------------------
//
// CLASS: dut_reference_model
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			this calss is mirror of DUT.
// 			for specification of DUT check DUT specification
//
//-------------------------------------------------------------------------------------

class dut_reference_model extends uvm_component;

	dut_register_block  dut_register_model;

	uvm_reg_map 	dut_register_map;

	// registers
	uvm_reg MATCH_p;
	uvm_reg	SWRESET_p;
	uvm_reg COUNTER_p;
	uvm_reg CFG_p;
	uvm_reg RIS_p;
	uvm_reg MIS_p;
	uvm_reg IM_p;
	uvm_reg IIR_p;
	uvm_reg LOAD_p;

	// register fields
	uvm_reg_field CFG_counter_enable_p;
	uvm_reg_field CFG_direction_p;

	uvm_reg_field RIS_overflow_p;
	uvm_reg_field RIS_underflow_p;
	uvm_reg_field RIS_match_p;

	uvm_reg_field MIS_overflow_p;
	uvm_reg_field MIS_underflow_p;
	uvm_reg_field MIS_match_p;

	uvm_reg_field IM_overflow_p;
	uvm_reg_field IM_underflow_p;
	uvm_reg_field IM_match_p;

	uvm_reg_field IIR_interrupt_priority_p;

	uvm_reg_field MATCH_compare_p;

	uvm_reg_field LOAD_compare_p;

	uvm_reg_field COUNT_counter;

	// virtual interface
	virtual interface dut_helper_vif vif;

	uvm_analysis_imp#(.T(axi_frame), .IMP(dut_reference_model))  	write_monitor_import;
	event swreset_event;

	// helper variables for disabling assertions
	int irq_check = 0;
	int dout_check = 0;

	`uvm_component_utils(dut_reference_model)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		write_monitor_import 	= new("write_monitor_import", 	this);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual dut_helper_vif)::get(this, "", "dut_vif", vif))
			 `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
	endfunction : build_phase

	extern task main();
	extern task counter_main_loop();
	extern task init();
	extern task update_vif_checks();
	extern function void write(input axi_frame axi_frame);

endclass : dut_reference_model

	task dut_reference_model::main();
		this.init();
	    fork
		    this.counter_main_loop();
		    this.update_vif_checks();
	    join
	endtask

	task dut_reference_model::counter_main_loop();
		bit[15 : 0] internal_counter;
		forever begin
			@(posedge vif.sig_fclock);
			if (vif.sig_reset == 0) begin
				void'(RIS_p	 .predict(0));
				void'(IM_p	 .predict(0));
				void'(MIS_p	 .predict(0));
				void'(LOAD_p .predict(0));
				void'(CFG_p	 .predict(0));
				void'(IIR_p	 .predict(0));
				void'(MATCH_p.predict(0));
				void'(COUNTER_p.predict(0));
				internal_counter = 0;
			end
			else begin
				if(!COUNT_counter.value)
					internal_counter = 0;
				if(CFG_counter_enable_p.value == 1) begin
					// down
					if (CFG_direction_p.value) begin
						internal_counter--;
						void'(COUNT_counter.predict(internal_counter));
						if(internal_counter == 'hffff) begin
							void'(RIS_underflow_p.predict(1));
							if(IM_underflow_p.value == 1) begin
								void'(MIS_underflow_p.predict(1));
								if(IIR_interrupt_priority_p.value < 1 )
									void'(IIR_interrupt_priority_p.predict(1));
							end
						end
					end
					// up
					else begin
						internal_counter++;
						void'(COUNT_counter.predict(internal_counter));
						if(internal_counter == 0) begin
							void'(RIS_overflow_p.predict(1));
							if(IM_overflow_p.value == 1) begin
								void'(MIS_overflow_p.predict(1));
								if(IIR_interrupt_priority_p.value < 2)
									void'(IIR_interrupt_priority_p.predict(2));
							end
						end
					end
				end // if counter_enable == 1 end

				// check for match interrupt
				if(MATCH_compare_p.value == COUNT_counter.value) begin
					if (!RIS_match_p.value)	begin
						void'(RIS_match_p.predict(1));
						if(IM_match_p.value == 1) begin
							void'(MIS_match_p.predict(1));
							void'(IIR_interrupt_priority_p.predict(3));
						end
					end
				end

			end // else (no reset)
		end // forever begin end
	endtask : counter_main_loop


	task dut_reference_model::init();
		dut_register_map = 	dut_register_model.get_default_map();

		SWRESET_p 	= dut_register_map.get_reg_by_offset(SWRESET_address_offset);

		COUNTER_p 	= dut_register_map.get_reg_by_offset(COUNT_address_offset);
		$cast(COUNT_counter, COUNTER_p.get_field_by_name(counter_string));

		CFG_p		= dut_register_map.get_reg_by_offset(CFG_address_offset);
		$cast(CFG_counter_enable_p,	 	CFG_p.get_field_by_name(counter_enable_string));
		$cast(CFG_direction_p, 			CFG_p.get_field_by_name(counter_direction_string));

		RIS_p		= dut_register_map.get_reg_by_offset(RIS_address_offset);
		$cast(RIS_overflow_p,	RIS_p.get_field_by_name(overflow_string));
		$cast(RIS_underflow_p, 	RIS_p.get_field_by_name(underflow_string));
		$cast(RIS_match_p,		RIS_p.get_field_by_name(match_string));

		MIS_p		= dut_register_map.get_reg_by_offset(MIS_address_offset);
		$cast(MIS_overflow_p, 	MIS_p.get_field_by_name(overflow_string));
		$cast(MIS_underflow_p, 	MIS_p.get_field_by_name(underflow_string));
		$cast(MIS_match_p,		MIS_p.get_field_by_name(match_string));


		IM_p		= dut_register_map.get_reg_by_offset(IM_address_offset);
		$cast(IM_overflow_p, 	IM_p.get_field_by_name(overflow_string));
		$cast(IM_underflow_p, 	IM_p.get_field_by_name(underflow_string));
		$cast(IM_match_p,		IM_p.get_field_by_name(match_string));

		IIR_p 		= dut_register_map.get_reg_by_offset(IIR_address_offset);
		$cast(IIR_interrupt_priority_p, IIR_p.get_field_by_name(interrupt_priority_string));

		MATCH_p		= dut_register_map.get_reg_by_offset(MATCH_address_offset);
		$cast(MATCH_compare_p, MATCH_p.get_field_by_name(compare_string));

		LOAD_p 		= dut_register_map.get_reg_by_offset(LOAD_address_offset);
		$cast(LOAD_compare_p, LOAD_p.get_field_by_name(compare_string));
	endtask : init

	task dut_reference_model::update_vif_checks();
		fork
			// irq and dout check
			forever begin
				// DOUT_O and IRQ_O are sensitive to the AXI_ACLK signal
				@(posedge vif.sig_aclock);

				// get value for output signals
				// irq
				if (MIS_overflow_p.value || MIS_match_p.value || MIS_underflow_p.value) begin
					if(!vif.irq_value)
						irq_check = TOLERANCE;
					vif.irq_value = 1;
				end
				else begin
					if(vif.irq_value)
						irq_check = TOLERANCE;
					vif.irq_value = 0;
				end

				// dout
				if (COUNT_counter.value > LOAD_compare_p.value) begin
					if(!vif.dout_value)
						dout_check = TOLERANCE;
					vif.dout_value = 1;
				end
				else begin
					if(vif.dout_value)
						dout_check = TOLERANCE;
					vif.dout_value = 0;
				end

				// disable checks if needed
				// dout
				if(dout_check) begin
					vif.dout_check = 0;
					dout_check--;
				end
				else
					vif.dout_check = 1;

				// irq
				if(irq_check) begin
					vif.irq_check = 0;
					irq_check--;
				end
				else
					vif.irq_check = 1;
			end

			// swreset check
			forever begin
				@swreset_event;
				@(posedge vif.sig_aclock);
				vif.swreset_value = 1;
				@(posedge vif.sig_aclock);
				vif.swreset_value = 0;
			end
		join
	endtask : update_vif_checks

//------------------------------------------------------------------------------
/**
* Function : write
* Purpose : when the write monitor collects a transaction, check if it correctly
*			writes to the SWRESET reg and resets all registers and if so
*			signal that event so that the vif checks can be updated accordingly
* Parameters : axi_frame - input frame from monitor
* Return :
**/
//------------------------------------------------------------------------------
	function void dut_reference_model::write(input axi_frame axi_frame);
		// if the frame is correct
		if((!axi_frame.len) && (axi_frame.size == 1) && (!axi_frame.burst_type)) begin
			// swreset
			if((axi_frame.addr == 10) && (axi_frame.data[0] == 'h5a)) begin
				-> swreset_event;
				irq_check = TOLERANCE;
				dout_check = TOLERANCE;
			end
		end
	endfunction

`endif