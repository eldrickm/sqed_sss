# SQED + Symbolic Starting States on steelcore

A demonstration of Symbolic Quick Error Detection with Symbolic Starting States

This directory contains the example deployed on
[steel]()

This codebases uses Mentor Questa Formal.

## Setup:
    1. Run on rsg10.stanford.edu. Be sure to use ssh -Y to interact
       with the GUI
    2. `source setup.bashrc`


## Commands:
    - `make clean` to clean the workspace
    - `make workspace` to create a workspace
    - `make patch` to patch design files
    - `make design` to pull in the design
    - `make compile` to compile the design
    - `make prove` to run the formal tools
    - `make gui` to visualize the results
      (you may need to manually open this using the output from `make prove`)
    - `make all` to run all of the above in proper sequence


## Demo
