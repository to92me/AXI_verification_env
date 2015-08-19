`ifndef AXI_SLAVE_WRITE_RESPONSE_DRIVER_SVH
`define AXI_SLAVE_WRITE_RESPONSE_DRIVER_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_slave_write_response_driver extends uvm_component;

	static axi_slave_write_response_driver 		driverInstance;



	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils(axi_slave_write_response_driver)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern static function axi_slave_write_response_driver getDriverInstace(uvm_component parent);

endclass : axi_slave_write_response_driver

function axi_slave_write_response_driver axi_slave_write_response_driver::getDriverInstace(input uvm_component parent);
    if(driverInstance == null)
	    begin
		    $display("Creating Axi Slave Write Response Driver");
		    driverInstance = new("AxiSlaveWriteResponseDriver", parent);
	    end
   return driverInstance;
endfunction

`endif
