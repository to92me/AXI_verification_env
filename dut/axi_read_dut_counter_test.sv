// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_read_dut_counter_test.sv
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
* Description : one test case
*
* Classes : 1. axi_read_dut_counter_test
*           2. axi_read_burst_dut_counter
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// Class: axi_read_burst_dut_counter
//
//------------------------------------------------------------------------------
/**
* Description : burst frame with default values for all possible signals
**/
// -----------------------------------------------------------------------------
class axi_read_burst_dut_counter extends axi_pkg::axi_read_burst_frame;

    `uvm_object_utils(axi_read_burst_dut_counter)

    constraint default_ct {valid_burst == 1; burst_type == FIXED; size == 1; len == 0; addr == 12; delay == 0;}

endclass : axi_read_burst_dut_counter

//------------------------------------------------------------------------------
//
// TEST: axi_read_dut_counter_test
//
//------------------------------------------------------------------------------
/**
* Description : test for the counter
**/
// -----------------------------------------------------------------------------
class axi_read_dut_counter_test extends uvm_test;

    axi_read_counter_tb tb0;
    uvm_table_printer printer;

    `uvm_component_utils_begin(axi_read_dut_counter_test)
        `uvm_field_object(tb0, UVM_ALL_ON)
    `uvm_component_utils_end

    function new(string name = "axi_read_dut_counter_test", uvm_component parent);
        super.new(name,parent);
        printer = new();
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        // Enable transaction recording for everything
        set_config_int("*", "recording_detail", UVM_FULL);
        // collect coverage or not
        uvm_config_int::set(this, "tb0.axi0.*", "coverage_enable", 1);
        // perform checks in monitor
        uvm_config_int::set(this, "tb0.axi0.*", "checks_enable", 1);
        // early termination of bursts
        uvm_config_int::set(this, "*", "terminate_enable", 0);
        // randomizing ready signal for master
        uvm_config_int::set(this, "tb0.axi0.read_master.driver", "master_ready_rand_enable", 0);
        // type overrides
        set_type_override_by_type(axi_pkg::axi_read_burst_frame::get_type(), axi_read_burst_dut_counter::get_type());

        // sequences
        uvm_config_wrapper::set(this, "tb0.virtual_seqr.run_phase", "default_sequence",
                                                     virtual_transfer_dut_counter::get_type());

        super.build_phase(phase);
        tb0 = axi_read_counter_tb::type_id::create("tb0", this);

    endfunction : build_phase

    task run_phase(uvm_phase phase);
        printer.knobs.depth = 5;
        // this.print(printer);
        // Use the drain time for this phase
        phase.phase_done.set_drain_time(this, 200);
    endtask : run_phase

endclass : axi_read_dut_counter_test