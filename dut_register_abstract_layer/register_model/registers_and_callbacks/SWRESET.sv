`ifndef SWRESET_REGISTER_SVH
`define SWRESET_REGISTER_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------


//============================== SWRESET SPEC ==================================================
//- SWRESET registar - ispravan upis sifre 0x5a resetuje sve registre
//                                  - neispravan upis sifre ne radi nista
//                                  - citanjem registra dobija se vrednost 0
//===========================================================================================

class SWRESET extends uvm_reg;
	rand uvm_reg_field reset_passcode;

	`uvm_object_utils(SWRESET)

	function new (string name = "SWRESET");
		super.new(.name(name), .nbits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction

	function void build();
	reset_passcode = uvm_reg_field::type_id::create(reset_passcode_string);
		reset_passcode.configure(.parent				(this					),
							.size						(16						),
							.lsb_pos			    	(SWRESET_passcode_offset),
							.access						("RW"					),
							.volatile					(0						),
							.reset						(16'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );
		begin
			SWRESET_reset_passcode_cb _SWRESET_reset_passcode_cb = new("SWRESET_reset_passcode_cb");
			uvm_reg_field_cb::add(reset_passcode, _SWRESET_reset_passcode_cb);
		end
	endfunction

endclass

class SWRESET_reset_passcode_cb extends uvm_reg_cbs;
	uvm_reg		IIR_p;
	uvm_reg		MIS_p;
	uvm_reg		RIS_p;
	uvm_reg		IM_p;
	uvm_reg		LOAD_p;
	uvm_reg 	CFG_p;
	uvm_reg		MATCH_p;
	uvm_reg		COUNT_p;


	function new(input string name = "SWRESET_reset_passcode_cb");
		super.new(name);
		this.init();
	endfunction


	function void init();
		RIS_p 	= map.get_reg_by_offset(RIS_address_offset	);
		IM_p 	= map.get_reg_by_offset(IM_address_offset	);
		MIS_p 	= map.get_reg_by_offset(MIS_address_offset	);
		LOAD_p 	= map.get_reg_by_offset(LOAD_address_offset	);
		CFG_p 	= map.get_reg_by_offset(CFG_address_offset	);
		IIR_p 	= map.get_reg_by_offset(IIR_address_offset	);
		MATCH_p = map.get_reg_by_offset(MATCH_address_offset);
		COUNT_p = map.get_reg_by_offset(COUNT_address_offset);
	endfunction


	function void post_predict(input uvm_reg_field  fld,
                                      input uvm_reg_data_t previous,
                                      inout uvm_reg_data_t value,
                                      input uvm_predict_e  kind,
                                      input uvm_path_e     path,
                                      input uvm_reg_map    map);



	if(kind == UVM_PREDICT_WRITE && value == 'h5A)
		begin
			// is passcode is correct everything will be reseted // VIDETI DA LI CE PROCI
			void'(RIS_p.predict(0));
			void'(IM_p.predict(0));
			void'(MIS_p.predict(0));
			void'(LOAD_p.predict(0));
			void'(CFG_p.predict(0));
			void'(IIR_p.predict(0));
			void'(MATCH_p.predict(0));
			void'(COUNT_p.predict(0));
			void'(fld.predict(0));
			value = 0;
		end

	endfunction

endclass



`endif