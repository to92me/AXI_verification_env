// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_read_slave_bad_id.sv
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
* Classes : 1. axi_read_slave_bad_id
*           2. axi_read_single_frame_bad_id
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// Class: axi_read_single_frame_bad_id
//
//------------------------------------------------------------------------------
/**
* Description : single frame with bad id
**/
// -----------------------------------------------------------------------------
class axi_read_single_frame_bad_id extends axi_pkg::axi_read_single_addr;

    `uvm_object_utils(axi_read_single_frame_bad_id)

    constraint valid_ct {id_mode == BAD_ID; resp_mode == GOOD_RESP; last_mode == GOOD_LAST_BIT; correct_lane == 1; read_enable == 0;}
    
endclass : axi_read_single_frame_bad_id

//------------------------------------------------------------------------------
//
// TEST: axi_read_slave_bad_id
//
//------------------------------------------------------------------------------
/**
* Description : test with where all the single frames send bad last signal
**/
// -----------------------------------------------------------------------------
class axi_read_slave_bad_id extends axi_read_base_test;

    `uvm_component_utils(axi_read_slave_bad_id)

    function new(string name = "axi_read_slave_bad_id", uvm_component parent);
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
        uvm_config_int::set(this, "tb0.axi0.read_master.driver", "master_ready_rand_enable", 1);
        // radnomizing ready signal for slave
        uvm_config_int::set(this, "tb0.axi0.read_slave*.driver", "slave_ready_rand_enable", 1);
        // actions based on region signal
        uvm_config_int::set(this, "tb0.axi0.read_slave*.sequencer.arbit", "region_enable", 0);

        // type overrides
        set_type_override_by_type(axi_pkg::axi_read_burst_frame::get_type(), axi_read_valid_burst_frame::get_type());
        set_type_override_by_type(axi_pkg::axi_read_single_addr::get_type(), axi_read_single_frame_bad_id::get_type());

        // sequences
        uvm_config_wrapper::set(this, "tb0.virtual_seqr.run_phase", "default_sequence",
                                                     virtual_transfer_multiple_addr::get_type());
        uvm_config_wrapper::set(this, "tb0.axi0.read_slave*.sequencer.run_phase", "default_sequence",
                                                     axi_slave_read_simple_two_phase_seq::get_type());

        super.build_phase(phase);

    endfunction : build_phase

endclass : axi_read_slave_bad_id