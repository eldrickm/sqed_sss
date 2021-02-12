# SQED + Symbolic Starting States on vscale

A demonstration of Symbolic Quick Error Detection with Symbolic Starting States
for detection of hardware trojans.

This directory contains the example deployed on
[vscale](https://github.com/LGTMCU/vscale)
a small, in-order RISC-V processor implementation written in Verilog.

This codebases uses Mentor Questa Formal.

Much of this is based on work by Shashank Nuthakki.
This repository is a cleaned up version of Saranyuc3/Trojan-Counter.


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
    - Open `toppipe.v`
    - Search "[TROJAN TRIGGER START]" to find the mechanism that activates the trojan
    - Search "[TROJAN PAYLOAD START]" to find the trojan's effect
    - `make all` to run the full formal verification process
    - The design will compile and Questa will begin running shortly after
    - On rsg10 with a typical 128b ticking time bomb trojan, it will take less than a few seconds for all assertions to fire


## Previous Notes by Shashank
    - qed_i_cache has been modified to have a shift-on-pop implementation of the
      queue instead of a circular buffer as suggested by Aaron (from mentor)
