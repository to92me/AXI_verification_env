// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : dut_tb.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Andrea Erdeljan
*
* E-Mail : andrea.erdeljan@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : test bench
*
* Classes : dut_tb
**/
// -----------------------------------------------------------------------------

`ifndef dut_tb_SV
`define dut_tb_SV

`include "axi_uvc/sv/axi_virtual_sequencer.sv"
`include "axi_uvc/sv/axi_virtual_seq_lib.sv"

//------------------------------------------------------------------------------
//
// CLASS: dut_tb
//
//------------------------------------------------------------------------------
/**
* Description : test bench
*
* Functions : 1. new (string name, uvm_component parent)
*             2. build_phase(uvm_phase phase)
*             3. connect_phase(uvm_phase phase)
**/
// -----------------------------------------------------------------------------
class dut_tb extends uvm_env;

  // axi read environment
  axi_read_env axi0;

  // WRITE
  axi_write_env env;
  axi_write_configuration_wrapper configuration_wrapper;
  axi_write_conf uvc_configuration;

  // configuration object
  dut_config config_obj;

  // virtual seqr
  axi_virtual_sequencer virtual_seqr;

  `uvm_component_utils_begin(dut_tb)
    `uvm_field_object(axi0, UVM_ALL_ON)
    `uvm_field_object(config_obj, UVM_ALL_ON)

    // WRITE
       `uvm_field_object(env, UVM_ALL_ON)
      `uvm_field_object(configuration_wrapper, UVM_DEFAULT)
      `uvm_field_object(uvc_configuration, UVM_DEFAULT)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Additional class methods
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

endclass : dut_tb

//------------------------------------------------------------------------------
/**
* Function : build_phase
* Purpose : build - propagate the configuration object and create environment
*           and virtual sequencer
* Parameters :  phase - uvm phase
* Return :  void
**/
//------------------------------------------------------------------------------
  function void dut_tb::build_phase(uvm_phase phase);
    super.build_phase(phase);

    config_obj = dut_config::type_id::create("config_obj");
    uvm_config_db#(axi_config)::set(this, "*", "axi_config", config_obj);

    axi0 = axi_read_env::type_id::create("axi0", this);
    virtual_seqr = axi_virtual_sequencer::type_id::create("virtual_seqr", this);

    // WRITE
    configuration_wrapper = axi_write_configuration_wrapper::getWraperInstance(this);
    uvc_configuration = configuration_wrapper.generateConfigurationObject();

        uvm_config_db#(axi_write_conf)::set(this, "*", "uvc_write_config", uvc_configuration);

        env  = axi_write_env::type_id::create("env", this);


  endfunction : build_phase

//------------------------------------------------------------------------------
/**
* Function : connect_phase
* Purpose : connect master sequencer to virtual sequencer
* Parameters :  phase - uvm phase
* Return :  void
**/
//------------------------------------------------------------------------------
  function void dut_tb::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    virtual_seqr.read_seqr = axi0.read_master.sequencer;
    virtual_seqr.write_seqr = env.master.sequencer;
  endfunction : connect_phase

`endif // dut_tb_SV
