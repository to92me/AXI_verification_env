`ifndef AXI_MASTER_WRITE_MSSG_SVH
`define AXI_MASTER_WRITE_MSSG_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

// axi mssg is for sending data to scheduler if package is ready or not

class axi_mssg ;

	axi_single_frame frame;
	axi_mssg_enum state;

endclass : axi_mssg


class unique_id_struct;
	id_type_enum id_status = UNIQUE_ID;
	bit [ID_WIDTH-1 : 0] ID;
endclass: unique_id_struct

class axi_waiting_resp;
	axi_frame  			 frame;
	int 				 counter;
endclass

class burst_package_info;
	bit [ID_WIDTH-1 : 0] 	ID;
	bit [ADDR_WIDTH -1: 0]	address;
	bit  [7:0]				wlen;
	burst_size_enum			wsize;
	burst_type_enum			wburst;


	// Get ID
	function bit[ID_WIDTH-1:0] getID();
		return ID;
	endfunction

	// Set ID
	function void setID(bit[ID_WIDTH-1:0] ID);
		this.ID = ID;
	endfunction

	// Get address
	function bit[ADDR_WIDTH-1:0] getAddress();
		return address;
	endfunction

	// Set address
	function void setAddress(bit[ADDR_WIDTH-1:0] address);
		this.address = address;
	endfunction

	// Get wburst
	function burst_type_enum getBurst();
		return wburst;
	endfunction

	// Set wburst
	function void setBurst(burst_type_enum wburst);
		this.wburst = wburst;
	endfunction

	// Get wlen
	function bit[7:0] getwLen();
		return wlen;
	endfunction

	// Set wlen
	function void setWlen(bit[7:0] wlen);
		this.wlen = wlen;
	endfunction

	// Get wsize
	function burst_size_enum getWsize();
		return wsize;
	endfunction

	// Set wsize
	function void setWsize(burst_size_enum wsize);
		this.wsize = wsize;
	endfunction




endclass


class slave_ID;
	bit[ID_WIDTH - 1 : 0]   ID;
	true_false_enum			ID_setted;

	// Get ID
	function bit[ID_WIDTH-1:0] getID();
		return ID;
	endfunction : getID

	// Set ID
	function void setID(bit[ID_WIDTH-1:0] ID);
		this.ID = ID;
	endfunction : setID

	// Get ID_setted
	function true_false_enum getID_setted();
		return ID_setted;
	endfunction : getID_setted

	// Set ID_setted
	function void setID_setted(true_false_enum ID_setted);
		this.ID_setted = ID_setted;
	endfunction : setID_setted



endclass


class axi_slave_response;
	bit [ID_WIDTH-1 : 0]	ID;
	response_enum 			rsp;

	// Get ID
	function bit[ID_WIDTH-1:0] getID();
		return ID;
	endfunction : getID

	// Set ID
	function void setID(bit[ID_WIDTH-1:0] ID);
		this.ID = ID;
	endfunction : setID

	// Get rsp
	function response_enum getRsp();
		return rsp;
	endfunction : getRsp

	// Set rsp
	function void setRsp(response_enum rsp);
		this.rsp = rsp;
	endfunction : setRsp



endclass


class axi_slave_write_addr_mssg ;
	bit [ID_WIDTH-1 : 0]	ID;
	bit [7 : 0]				len;
	true_false_enum			last_one;
	bit [ADDR_WIDTH -1 : 0] addr;

	// Get addr
	function bit[ADDR_WIDTH-1:0] getAddr();
		return addr;
	endfunction : getAddr

	// Set addr
	function void setAddr(bit[ADDR_WIDTH-1:0] addr);
		this.addr = addr;
	endfunction : setAddr



	// Get len
	function true_false_enum getLast_one();
		return last_one;
	endfunction

	// Set len
	function void setLast_one(true_false_enum last_one);
		this.last_one = last_one;
	endfunction


	// Get ID
	function bit[ID_WIDTH-1:0] getID();
		return ID;
	endfunction

	// Set ID
	function void setID(bit[ID_WIDTH-1:0] ID);
		this.ID = ID;
	endfunction

	// Get len
	function bit[7:0] getLen();
		return len;
	endfunction

	// Set len
	function void setLen(bit[7:0] len);
		this.len = len;
	endfunction

endclass



class axi_slave_write_data_mssg;
	bit [ID_WIDTH-1 : 0]	ID;
	true_false_enum 		last_one;
	bit [DATA_WIDTH-1 : 0 ]	data;
	bit [STRB_WIDTH-1 : 0 ] strobe;

	function true_false_enum getLast_one();
		return last_one;
	endfunction

	function void setLast_one(true_false_enum set_last );
		this.last_one = set_last;
	endfunction

	// Get ID
	function bit[ID_WIDTH-1:0] getID();
		return ID;
	endfunction : getID

	// Set ID
	function void setID(bit[ID_WIDTH-1:0] ID);
		this.ID = ID;
	endfunction : setID

	// Get data
	function bit[DATA_WIDTH-1:0] getData();
		return data;
	endfunction

	// Set data
	function void setData(bit[DATA_WIDTH-1:0] data);
		this.data = data;
	endfunction

	// Get strobe
	function bit[STRB_WIDTH-1:0] getStrobe();
		return strobe;
	endfunction

	// Set strobe
	function void setStrobe(bit[STRB_WIDTH-1:0] strobe);
		this.strobe = strobe;
	endfunction



endclass

class axi_slave_write_rsp_mssg;
	bit [ID_WIDTH-1 : 0]	ID;
	response_enum			rsp;

	// Get ID
	function bit[ID_WIDTH-1:0] getID();
		return ID;
	endfunction : getID

	// Set ID
	function void setID(bit[ID_WIDTH-1:0] ID);
		this.ID = ID;
	endfunction : setID

	// Get rsp
	function response_enum getRsp();
		return rsp;
	endfunction : getRsp

	// Set rsp
	function void setRsp(response_enum rsp);
		this.rsp = rsp;
	endfunction : setRsp



endclass

class axi_slave_memory_response;


	axi_slave_config_memory_field memory_field;
	true_false_enum valid_data = FALSE;

	function new();
		memory_field = new();
	endfunction

	extern function 	bit [DATA_WIDTH-1 : 0]  		getData();
	extern function 	bit [ADDR_WIDTH-1 : 0]  		getAddr();
	extern function 	true_false_enum 				getValid();
	extern function 	axi_slave_config_memory_field 	getField();

	extern function void	setData(input bit [DATA_WIDTH-1 : 0] write_data);
	extern function void	setAddr(input bit [ADDR_WIDTH-1 : 0] write_addr);
	extern function void 	setValid(input true_false_enum write_valid);
	extern function void	setField(input axi_slave_config_memory_field write_field);


endclass

function bit [ADDR_WIDTH-1 : 0] axi_slave_memory_response::getAddr();
    return memory_field.addr;
endfunction

function bit [DATA_WIDTH-1 : 0] axi_slave_memory_response::getData();
    return memory_field.data;
endfunction

function axi_slave_config_memory_field axi_slave_memory_response::getField();
    return memory_field;
endfunction

function true_false_enum axi_slave_memory_response::getValid();
    return valid_data;
endfunction

function void axi_slave_memory_response::setAddr(input bit[ADDR_WIDTH-1:0] write_addr);
    this.memory_field.addr = write_addr;
endfunction

function void axi_slave_memory_response::setData(input bit[DATA_WIDTH-1:0] write_data);
    this.memory_field.data = write_data;
endfunction

function void axi_slave_memory_response::setField(input axi_slave_config_memory_field write_field);
    this.memory_field = write_field;
endfunction

function void axi_slave_memory_response::setValid(input true_false_enum write_valid);
	this.valid_data = write_valid;
endfunction

class axi_write_address_collector_mssg extends uvm_sequence_item;
	bit[ID_WIDTH	-1 	: 0]		id;
	bit[ADDR_WIDTH 	- 1 : 0]		addr;
	bit [7:0]						len;
	burst_size_enum					size;
	burst_type_enum					burst_type;
	lock_enum						lock;
	bit [3:0]						cache;
	bit [2:0]						prot;
	bit [3:0]						qos;
	bit [3:0]						region;
	//								user;

 	function new();
	 	super.new("axi_write_address_collector_mssg");
 	endfunction

	// Get addr
	function bit[ADDR_WIDTH-1:0] getAddr();
		return addr;
	endfunction

	// Set addr
	function void setAddr(bit[ADDR_WIDTH-1:0] addr);
		this.addr = addr;
	endfunction

	// Get burst_type
	function burst_type_enum getBurst_type();
		return burst_type;
	endfunction

	// Set burst_type
	function void setBurst_type(burst_type_enum burst_type);
		this.burst_type = burst_type;
	endfunction

	// Get cache
	function bit[3:0] getCache();
		return cache;
	endfunction

	// Set cache
	function void setCache(bit[3:0] cache);
		this.cache = cache;
	endfunction

	// Get id
	function bit[ID_WIDTH-1:0] getId();
		return id;
	endfunction

	// Set id
	function void setId(bit[ID_WIDTH-1:0] id);
		this.id = id;
	endfunction

	// Get len
	function bit[7:0] getLen();
		return len;
	endfunction

	// Set len
	function void setLen(bit[7:0] len);
		this.len = len;
	endfunction

	// Get lock
	function lock_enum getLock();
		return lock;
	endfunction

	// Set lock
	function void setLock(lock_enum lock);
		this.lock = lock;
	endfunction

	// Get prot
	function bit[2:0] getProt();
		return prot;
	endfunction

	// Set prot
	function void setProt(bit[2:0] prot);
		this.prot = prot;
	endfunction

	// Get qos
	function bit[3:0] getQos();
		return qos;
	endfunction

	// Set qos
	function void setQos(bit[3:0] qos);
		this.qos = qos;
	endfunction

	// Get region
	function bit[3:0] getRegion();
		return region;
	endfunction

	// Set region
	function void setRegion(bit[3:0] region);
		this.region = region;
	endfunction

	// Get size
	function burst_size_enum getSize();
		return size;
	endfunction

	// Set size
	function void setSize(burst_size_enum size);
		this.size = size;
	endfunction

	function void copyMssg(ref axi_write_address_collector_mssg copy_mssg);
		this.addr			= copy_mssg.getAddr();
		this.burst_type 	= copy_mssg.getBurst_type();
		this.cache 			= copy_mssg.getCache();
		this.id 			= copy_mssg.getId();
		this.len 			= copy_mssg.getLen();
		this.lock 			= copy_mssg.getLock();
		this.prot 			= copy_mssg.getProt();
		this.qos 			= copy_mssg.getQos();
		this.region 		= copy_mssg.getRegion();
		this.size 			= copy_mssg.getSize();
	endfunction
endclass

class axi_write_data_collector_mssg extends uvm_sequence_item;
	bit[ID_WIDTH - 1 	: 0]		id;
	bit[DATA_WIDTH - 1 	: 0]    	data;
	bit[STRB_WIDTH - 1 	: 0]		strobe;
	true_false_enum					last;

	function new();
	 	super.new("axi_write_data_collector_mssg");
 	endfunction

	// Get data
	function bit[DATA_WIDTH-1:0] getData();
		return data;
	endfunction

	// Set data
	function void setData(bit[DATA_WIDTH-1:0] data);
		this.data = data;
	endfunction

	// Get id
	function bit[ID_WIDTH-1:0] getId();
		return id;
	endfunction

	// Set id
	function void setId(bit[ID_WIDTH-1:0] id);
		this.id = id;
	endfunction

	// Get last
	function true_false_enum getLast();
		return last;
	endfunction

	// Set last
	function void setLast(true_false_enum last);
		this.last = last;
	endfunction

	// Get strobe
	function bit[STRB_WIDTH-1:0] getStrobe();
		return strobe;
	endfunction

	// Set strobe
	function void setStrobe(bit[STRB_WIDTH-1:0] strobe);
		this.strobe = strobe;
	endfunction

	function void copyMssg(ref axi_write_data_collector_mssg copy_mssg);
		this.data 	= copy_mssg.getData();
		this.id 	= copy_mssg.getId();
		this.last 	= copy_mssg.getLast();
		this.strobe = copy_mssg.getStrobe();
	endfunction
endclass

class axi_write_response_collector_mssg extends uvm_sequence_item;
	bit [ID_WIDTH-1 : 0]		id;
	bit [1:0]					bresp;

	function new();
	 	super.new("axi_write_response_collector_mssg");
 	endfunction


	// Get bresp
	function bit[1:0] getResp();
		return bresp;
	endfunction

	// Set bresp
	function void setResp(bit[1:0] bresp);
		this.bresp = bresp;
	endfunction

	// Get id
	function bit[ID_WIDTH-1:0] getId();
		return id;
	endfunction

	// Set id
	function void setId(bit[ID_WIDTH-1:0] id);
		this.id = id;
	endfunction

	function void copyMssg(ref axi_write_response_collector_mssg copy_mssg);
		this.bresp	= copy_mssg.getResp();
		this.id 	= copy_mssg.getId();
	endfunction

endclass

`endif

