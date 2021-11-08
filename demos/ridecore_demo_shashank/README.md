# SQED + Symbolic Starting States on Ridecore

A demonstration of Symbolic Quick Error Detection with Symbolic Starting States
for detection of hardware trojans.

This directory contains the example deployed on
[Ridecore](https://github.com/ridecore/ridecore)

This codebases uses Mentor Questa Formal.

Much of this is based on work by Shashank Nuthakki.
This repository is a cleaned up version of a directory found on the rsg cluster
`/pool0/esingh/archive/sqed/trojans/ride-with-2QED-sss/results-ride-with-2QED-sss-withlw-srcforw`

## Setup:
    1. Run on rsg10.stanford.edu. Be sure to use ssh -Y to interact
       with the GUI
    2. `source setup.bashrc`


## Commands:
    - `make clean` to clean the workspace
    - `make workspace` to create a workspace
    - `make design` to pull in the design
    - `make compile` to compile the design
    - `make prove` to run the formal tools
    - `make gui` to visualize the results
      (you may need to manually open this using the output from `make prove`)
    - `make all` to run all of the above in proper sequence


## Demo
    - Open `ridecore/pipeline.v`
    - Search "[TROJAN TRIGGER START]" to find the mechanism that activates the trojan
    - Search "[TROJAN PAYLOAD START]" to find the trojan's effect
    - `make all` to run the full formal verification process
    - The design will compile and Questa will begin running shortly after
    - On rsg10 with a typical 128b ticking time bomb trojan, it can take up to 30 mins for all assertions to fire


## Previous Notes by Shashank
    The following abstractions has been made to ridecore:
    i) memory has only 64 entries (32 for orig)
    ii) queue for qed_i_cache is only 32 entries.
    iii) getting rid of undriven wires:
    all undriven wires:
    Undriven Wires
    --------------
      pipe.ai_branch.b0  (2 bits)
      pipe.ai_ldst.b0  (2 bits)
      pipe.aregfile.comreg1_tag  (6 bits)
      pipe.aregfile.comreg2_tag  (6 bits)
      pipe.aregfile.rt.tag0  (32 bits)
      pipe.aregfile.rt.tag1  (32 bits)
      pipe.aregfile.rt.tag2  (32 bits)
      pipe.aregfile.rt.tag3  (32 bits)
      pipe.aregfile.rt.tag4  (32 bits)
      pipe.aregfile.rt.tag5  (32 bits)
      pipe.pc_mul  (32 bits)
      pipe.pipe_if.gsh.prhisttbl.pht0.wdataa  (2 bits)
      pipe.pipe_if.gsh.prhisttbl.pht1.wdataa  (2 bits)

    got rid of:
    --------------
      pipe.ai_branch.b0  (2 bits)
      pipe.ai_ldst.b0  (2 bits)
      pipe.aregfile.comreg1_tag  (6 bits)
      pipe.aregfile.comreg2_tag  (6 bits)
      pipe.aregfile.rt.tag0  (32 bits)
      pipe.aregfile.rt.tag1  (32 bits)
      pipe.aregfile.rt.tag2  (32 bits)
      pipe.aregfile.rt.tag3  (32 bits)
      pipe.aregfile.rt.tag4  (32 bits)
      pipe.aregfile.rt.tag5  (32 bits)
      pipe.pc_mul  (32 bits)
    // I didn't get rid of these signals b/c I'll be getting rid of
    // the entire pipe_if module

    iv) got rid of inst_mem in topsim.v
    v) got rid of the entire pipe_if module
    vi) got rid of the following RAMs: (got the reg count from 20k to 15k, but no improvement!)
     pipe.rob.bhr (Depth 64)
     pipe.rob.inst_pc (Depth 64)
     pipe.rob.jmpaddr (Depth 64)
     pipe.sb.spectag (Depth 32)


    vii) got rid of speculation logic in ARF

    -- by doing all the above changes I didn't find much improvement in the runtime: e.g. proof min of 10 went from 29 mins to 25 mins

    viii) got rid of rs_branch logic

    -- by doing just this the proof min of 10 went from 25 to 12 mins (nope, it didn't, it was just a one-off case)


    ix) got rid of the alloc-issue units and ex-branch unit too
    x) got rid of lw/sw rs unit and also the data_mem
    -- at this point the #regs are 11110 only

    xi) removed most of the logic in branch, ldst, mul pipelines (at this point the #regs are 8836 only, main reduction came when removed the storebuffer)

    -- by doing I'm able to push the bound to 12.
