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
**/
// -----------------------------------------------------------------------------

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

    `uvm_component_utils_begin(axi_read_dut_counter_test)
        `uvm_field_object(tb0, UVM_ALL_ON)
    `uvm_component_utils_end

    function new(string name = "axi_read_dut_counter_test", uvm_component parent);
        super.new(name,parent);
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

        // sequences
        uvm_config_wrapper::set(this, "tb0.virtual_seqr.run_phase", "default_sequence",
                                                     virtual_transfer_dut_counter::get_type());

        tb0 = axi_read_counter_tb::type_id::create("tb0", this);

        super.build_phase(phase);

    endfunction : build_phase

endclass : axi_read_dut_counter_test