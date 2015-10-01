`ifndef AXI_WRITE_CONFIGURATION_CORRECT_DATA_DELAY_SPEED
`define AXI_WRITE_CONFIGURATION_CORRECT_DATA_DELAY_SPEED
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_write_configuration_correct_data_delay_speed extends axi_write_user_config_base;

	`uvm_component_utils(axi_write_configuration_correct_data_delay_speed)

function new (string name, uvm_component parent);
		super.new(name, parent);
endfunction : new

function void setConfigurations();

registerConfiguration("general", "do_coverage", 		TRUE);
registerConfiguration("general", "do_checks", 			TRUE);
registerConfiguration("general", "correct_driving_vif", TRUE);
registerConfiguration("general", "axi_3_support",		FALSE);
registerConfiguration("general", "full_speed", 			TRUE);

endfunction

endclass : axi_write_configuration_correct_data_delay_speed


`endif