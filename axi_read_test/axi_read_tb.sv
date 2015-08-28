/*-----------------------------------------------------------------
File name     : axi_read_tb.sv
Developers    : Kathleen Meade
Created       : May 16, 2010
Description   : Simple Testbench to understand the AXI UVC
Notes         :
-------------------------------------------------------------------
Copyright 2010 (c) Cadence Design Systems
-----------------------------------------------------------------*/

`ifndef AXI_READ_TB_SV
`define AXI_READ_TB_SV

`include "sv/axi_virtual_sequencer.sv"
`include "sv/axi_virtual_seq_lib.sv"

//------------------------------------------------------------------------------
// CLASS: apb_axi_read_tb
//------------------------------------------------------------------------------

class axi_read_tb extends uvm_env;

  // apb environment
  axi_env axi0;

  // configuration object
  axi_read_test_config config_obj;

  // virtual seqr
  axi_virtual_sequencer virtual_seqr;

  `uvm_component_utils_begin(axi_read_tb)
    `uvm_field_object(axi0, UVM_ALL_ON)
    `uvm_field_object(config_obj, UVM_ALL_ON)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Additional class methods
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

endclass : axi_read_tb

  // UVM build_phase
  function void axi_read_tb::build_phase(uvm_phase phase);
    super.build_phase(phase);

    config_obj = axi_read_test_config::type_id::create("config_obj");
    uvm_config_db#(axi_config)::set(this, "*", "axi_config", config_obj);

    axi0 = axi_env::type_id::create("axi0", this);
    virtual_seqr = axi_virtual_sequencer::type_id::create("virtual_seqr", this);

  endfunction : build_phase

  // connect_phase
  function void axi_read_tb::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    virtual_seqr.read_seqr = axi0.read_master.sequencer;
  endfunction : connect_phase

`endif // axi_read_tb_SV