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
 extern function void bus2reg(input uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);

endclass : dut_register_model_adapter


function uvm_sequence_item dut_register_model_adapter::reg2bus(const ref uvm_reg_bus_op rw);
	dut_frame reg_frame;
	reg_frame = dut_frame::type_id::create("DutFrame");

	//specific to dut_reqister and operation
	reg_frame.addr = rw.addr;
	reg_frame.rw = (rw.kind == UVM_READ)? AXI_READ : AXI_WRITE;
	reg_frame.data[0] = rw.data;

	//dut burst configuration
	reg_frame.burst_type = FIXED;
	reg_frame.size = BYTE_2;
	reg_frame.len = 0;

	//"random" chose
	reg_frame.id =	0;

	//not of interes because dut doesn't supporst this options
	reg_frame.awuser = 0;
	reg_frame.cache = 0;
	reg_frame.prot = 0;
	reg_frame.lock = NORMAL;
	reg_frame.qos = 0;
	reg_frame.wuser = 0;

	return reg_frame;

endfunction

function void dut_register_model_adapter::bus2reg(input uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    dut_frame	bus_frame;

	if(! $cast(bus_frame, bus_item))
		`uvm_error(get_name(),"Monitor item can not be cast to axi_frame")

	rw.addr = bus_frame.addr;
	rw.kind = (bus_frame.rw == AXI_READ)? UVM_READ : UVM_WRITE ;

	rw.data = bus_frame.data.pop_front();

	if(bus_frame.data.size > 0)
		`uvm_warning(get_name(),"Has recieved axi_frame that contains more than one data in queue! Adpter is using just firs one");
	rw.n_bits = 16;
	if(bus_frame.resp == OKAY || bus_frame.resp == EXOKAY)
		begin
			rw.status = UVM_IS_OK;
			$display("UVM_IS_OK");
		end
	else
		begin
			$display("UVM_NOT_OK");
			rw.status = UVM_NOT_OK;
		end

endfunction

`endif