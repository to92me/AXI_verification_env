`ifndef DUT_REGISTER_MODEL_REFERECE_MODEL_SVH_TOME
`define DUT_REGISTER_MODEL_REFERECE_MODEL_SVH_TOME

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------



class dut_referece_model extends uvm_component;


	dut_register_block  dut_register_model;

	event clock;
	int clock_frek;
	uvm_reg_map 	dut_register_map;

	uvm_reg MATCH_p;
	uvm_reg	SWRESET_p;
	uvm_reg COUNTER_p;
	uvm_reg CFG_p;

	uvm_reg RIS_p;
	uvm_reg MIS_p;
	uvm_reg IM_p;
	uvm_reg IIR_p;


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

	uvm_reg_fielf COUNT_counter;


	virtual interface dut_helper_vif vif;


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
		if(!uvm_config_db#(virtual dut_helper_vif)::get(this, "", "dut_vif", vif))
			 `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
	endfunction : build_phase

	extern task main();
	extern task refereceModelMain();
	extern task init();

endclass : dut_referece_model

	task dut_referece_model::main();
		this.init();
	    fork
		    this.refereceModelMain();
	    join
	endtask



	task dut_referece_model::refereceModelMain();
		bit[15 : 0] internal_counter;
		forever begin
			@(posedge vif.sig_fclock);

			if(CFG_counter_enable_p.value == 1)
				begin
					case(CFG_direction_p.value)

// UP DIRECTION
						0:
						begin
							internal_counter++;
							COUNT_counter.predicti(internal_counter);
							if(internal_counter == 0)
								begin
									void'(RIS_overflow_p.predict(1));
									if(IM_overflow_p.value == 1)
										begin
											MIS_overflow_p.predict(1);
											if(IIR_interrupt_priority_p < 2)
												IIR_interrupt_priority_p.predict(2);
										end
								end

							if(internal_counter == MATCH_compare_p.value)
								begin
									void'(RIS_match_p.predict(1));
									if(IM_match_p.value == 1)
										begin
											MIS_match_p.predict(1);
											IIR_interrupt_priority_p.predict(3);
										end
								end
						end

// DOWN DIRECTION

						1:
						begin
							internal_counter--;
							COUNT_counter.predicti(internal_counter);
							if(internal_counter == 'hffff)
								begin
									void'(RIS_underflow_p.predict(1));
									if(IM_underflow_p.value == 1)
										begin
											MIS_underflow_p.predict(1);
											if(IIR_interrupt_priority_p < 1 )
												IIR_interrupt_priority_p.predict(1);
										end
								end

							if(internal_counter == MATCH_compare_p.value)
								begin
									void'(RIS_match_p.predict(1));
									if(IM_match_p.value == 1)
										begin
											MIS_match_p.predict(1);
											IIR_interrupt_priority_p.predict(3);
										end
								end

						end
					endcase

				end // if counter_enable == 1 end
			else
				begin
					if(MATCH_compare_p.value == COUNT_counter.value)
						begin
							RIS_match_p.predict(1);
							if(IM_match_p.value == 1)
								begin
									MIS_match_p.predict(1);
									IIR_interrupt_priority_p.predict(3);
								end

						end
					//if() // TODO
					// dodati scenario i
					// da je pod default active
					// dodati u dut helper if DOUT_O
					// dodati IRQ;
					// dodati checkere za signale  DOUT_O i IRQ
					//
				end

		end // foreve begin end
	endtask

	task dut_referece_model::init();
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
		$cast(IM_overflow_p, 	IM_p.get_field_by_name(underflow_string));
		$cast(IM_underflow_p, 	IM_p.get_field_by_name(overflow_string));
		$cast(IM_match_p,		IM_p.get_field_by_name(match_string));

		IIR_p 		= dut_register_map.get_reg_by_offset(IIR_address_offset);
		$cast(IIR_interrupt_priority_p, IIR_p.get_field_by_name(interrupt_priority_string));

		MATCH_p		= dut_register_map.get_reg_by_offset(MATCH_address_offset);
		$cast(MATCH_compare_p, MATCH_p.get_field_by_name(compare_string));


	endtask


`endif