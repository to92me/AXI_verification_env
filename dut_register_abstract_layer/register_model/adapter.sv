`ifndef DUT_ADAPTER_SVH_
`define DUT_ADAPTER_SVH_


//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class dut_register_model_adapter extends uvm_reg_adapter;

	`uvm_object_utils(dut_register_model_adapter)

	function new( string name = "" );
      super.new( name );
      supports_byte_enable = 0;
      provides_responses   = 1; // TODO PAZITI
      //0 ako stavim onda pravi cekiranje kada se posalje item done
      //1 onda radi cekiranje kada se posalje put resoponse
   endfunction: new

 extern function uvm_sequence_item reg2bus( const ref uvm_reg_bus_op rw );
 extern function void bus2reg( uvm_sequence_item bus_item, ref uvm_reg_bus_op rw );

endclass : dut_register_model_adapter


function uvm_sequence_item dut_register_model_adapter::reg2bus(const ref uvm_reg_bus_op rw);
	dut_frame reg_frame;
	reg_frame = dut_frame::type_id::create("DutFrame", this);

	//specific to dut_reqister and operation
	dut_frame.addr = rw.addr;
	dut_frame.rw = (rw.kind == UVM_READ)? AXI_READ : AXI_WRITE;

	//dut burst configuration
	dut_frame.burst_type = FIXED;
	dut_frame.size = BYTE_2;
	dut_frame.len = 0;

	//"random" chose
	dut_frame.id =	0;

	//not of interes because dut doesn't supporst this options
	dut_frame.awuser = 0;
	dut_frame.cache = 0;
	dut_frame.prot = 0;
	dut_frame.lock = NORMAL;
	dut_frame.qos = 0;
	dut_frame.wuser = 0;

	return dut_frame;

endfunction

function dut_register_model_adapter::bus2reg(input uvm_sequence_item frame, ref uvm_reg_bus_op rw);
    dut_frame	bus_frame;

	if(! $cast(frame, monitor_frame))
		`uvm_error(get_name(),"Monitor item can not be cast to axi_frame")

	rw.addr = bus_frame.addr;
	rw.kind = (bus_frame.rw == AXI_READ)? UVM_READ : UVM_WRITE ;
	rw.data = bus_frame.data.pop_front();
	if(bus_frame.data.size > 0)
		`uvm_warning(get_name(),"Has recieved axi_frame that contains more than one data in queue! Adpter is using just firs one");
	rw.n_bits = 16;
	rw.status = UVM_IS_OK;

endfunction

`endif