/*-----------------------------------------------------------------
File name     : test_lib.sv
Developers    : Kathleen Meade
Created       : Tue May  4 15:13:46 2010
Description   :
Notes         :
-------------------------------------------------------------------
Copyright 2010 (c) Cadence Design Systems
-----------------------------------------------------------------*/

//----------------------------------------------------------------
//
// TEST: demo_base_test - Base test
//
//----------------------------------------------------------------
class demo_base_test extends uvm_test;

  axi_read_tb tb0;
  uvm_table_printer printer;

  `uvm_component_utils_begin(demo_base_test)
   `uvm_field_object(tb0, UVM_ALL_ON)
 `uvm_component_utils_end

  function new(string name = "demo_base_test", uvm_component parent);
    super.new(name,parent);
    printer = new();
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Enable transaction recording for everything
    set_config_int("*", "recording_detail", UVM_FULL);
    uvm_config_int::set(this, "tb0.axi0.read_monitor", "coverage_enable", 1);
    tb0 = axi_read_tb::type_id::create("tb0", this);
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    printer.knobs.depth = 5;
    // this.print(printer);
    // Use the drain time for this phase
    phase.phase_done.set_drain_time(this, 200);
  endtask : run_phase

endclass : demo_base_test

//----------------------------------------------------------------
// TEST: test_simple
//----------------------------------------------------------------
class test_simple extends demo_base_test;

  `uvm_component_utils(test_simple)

  function new(string name = "test_simple", uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    // Set the default sequence for the master and slaves
    /*uvm_config_db #(uvm_object_wrapper)::set(this, "uvm_test_top.tb0.axi0.read_master.sequencer.run_phase",
                          "default_sequence", axi_master_read_transfer_seq::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this,"tb0.axi0.slave*sequencer.run_phase",
                          "default_sequence", axi_slave_read_simple_two_phase_seq::type_id::get());*/
    uvm_config_wrapper::set(this, "tb0.axi0.read_master.sequencer.run_phase", "default_sequence",
                           axi_master_read_transfer_seq::get_type());
    uvm_config_wrapper::set(this, "tb0.axi0.read_slave*.sequencer.run_phase", "default_sequence",
                           axi_slave_read_simple_two_phase_seq::get_type());
    // Create the tb
    super.build_phase(phase);
  endfunction : build_phase

endclass : test_simple
