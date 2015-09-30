// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_read_large_size.sv
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
* Classes : 1. axi_read_large_size
*           2. axi_read_burst_frame_large_size
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// Class: axi_read_burst_frame_large_size
//
//------------------------------------------------------------------------------
/**
* Description : burst frame with size larger than address boundary
**/
// -----------------------------------------------------------------------------
class axi_read_burst_frame_large_size extends axi_pkg::axi_read_burst_frame;

    `uvm_object_utils(axi_read_burst_frame_large_size)

    constraint size_ct {size > $clog2(DATA_WIDTH / 8);}

endclass : axi_read_burst_frame_large_size

//------------------------------------------------------------------------------
//
// TEST: axi_read_large_size
//
//------------------------------------------------------------------------------
/**
* Description : test size larger than address boundary
**/
// -----------------------------------------------------------------------------
class axi_read_large_size extends axi_read_base_test;

    `uvm_component_utils(axi_read_large_size)

    function new(string name = "axi_read_large_size", uvm_component parent);
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
        uvm_config_int::set(this, "*", "terminate_enable", 1);
        // randomizing ready signal for master
        uvm_config_int::set(this, "tb0.axi0.read_master.driver", "master_ready_rand_enable", 1);
        // radnomizing ready signal for slave
        uvm_config_int::set(this, "tb0.axi0.read_slave*.driver", "slave_ready_rand_enable", 1);
        // actions based on region signal
        uvm_config_int::set(this, "tb0.axi0.read_slave*.sequencer.arbit", "region_enable", 1);

        // type overrides
        set_type_override_by_type(axi_pkg::axi_read_burst_frame::get_type(), axi_read_burst_frame_large_size::get_type());
        set_type_override_by_type(axi_pkg::axi_read_single_addr::get_type(), axi_read_valid_single_frame::get_type());

        // sequences
        uvm_config_wrapper::set(this, "tb0.virtual_seqr.run_phase", "default_sequence",
                                                     virtual_transfer_single_burst::get_type());
        uvm_config_wrapper::set(this, "tb0.axi0.read_slave*.sequencer.run_phase", "default_sequence",
                                                     axi_slave_read_simple_two_phase_seq::get_type());

        super.build_phase(phase);

    endfunction : build_phase

endclass : axi_read_large_size