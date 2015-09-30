`ifndef AXI_WIRTE_CONFIGURATION_FULL_SPEED_SVH
`define AXI_WIRTE_CONFIGURATION_FULL_SPEED_SVH


class axi_write_configuration_full_speed extends axi_write_user_config_base;

`uvm_component_utils(axi_write_configuration_full_speed)

function new (string name, uvm_component parent);
		super.new(name, parent);
endfunction : new

function void setConfigurations();

//$display("Full speed Configuraton ");

registerConfiguration("general", "do_coverage", 		TRUE);
registerConfiguration("general", "do_checks", 			TRUE);
registerConfiguration("general", "correct_driving_vif", TRUE);
registerConfiguration("general", "axi_3_support",		FALSE);
registerConfiguration("general", "full_speed", 			TRUE);

endfunction

endclass




`endif