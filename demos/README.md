# SQED + Symbolic Starting States Demos

Looking to run a demo in this folder?
See [Usage](#usage)

Looking to deploy the SQED + SSS technique onto a new processor?
See [Deployment](#deployment)


## Overview

This folder contains demos of the SQED + SSS technique deployed on the following
processors:

- [picorv32](https://github.com/cliffordwolf/picorv32.git)
  A size-optimized, unpipelined RISC-V CPU (RV32I + M + C)

- [steel](https://github.com/rafaelcalcada/steel-core.git)
  A 3-stage, single-issue RISC-V CPU (RV32I + Zicsr + M Privilege)

- [cva6](https://github.com/openhwgroup/cva6.git)
  A 6-stage, single-issue RISC-V CPU (RV64I + M + A + C + M/S/U Privilege)

- [vscale](https://github.com/LGTMCU/vscale.git)
  *DEPRECATED* A RISC-V CPU

- [ridecore](https://github.com/ridecore/ridecore.git)
  *DEPRECATED* An OOO RISC-V CPU


The `*_shashank` folders are slightly modified copies of original demos
inherited from Srinivasa Shashank Nuthakki. They are not guaranteed compliant
with the standard demo structure described in [Deployment](#deployment) below


## Usage

Unless otherwise specified, the demos in this repo utilize the Questa toolchain
to compile and run formal analysis on each design.

The Questa toolchain is installed on the Robust Systems Group (RSG) Research
Computer Cluster at Stanford University. The following instructions and
scripts in this repo assume you have access to the RSG cluster. If you are a
Stanford affiliate and do not have access, please reach out to RSG members.

Follow the steps below to get started:

1. Log into RSG Cluster 10 (rsg10.stanford.edu) via SSH
   ```
   ssh -Y rsg10.stanford.edu
   ```
   If you are off-campus, you will need to access this via tunneling through
   a system open to external connections (such as myth) or via a VPN.

2. (Optional but Highly Recommended) Log into rsg10 via VNC
   For example,
   [MobaXterm](https://mobaxterm.mobatek.net) if on Windows or
   [RoyalTSX](https://www.royalapps.com/ts/mac/features) if on Mac.
   This will allow you to interact with the Questa GUI in a lower-latency,
   higher quality way than X Forwarding through SSH.

3. Clone the repo into a work area.
   On rsg10, you typically will want to put this in `pool0/[username]`
   ```
   mkdir /pool0/[username]
   cd /pool0/[username]
   git clone https://github.com/eldrickm/sqed_sss.git
   ```

4. Enter the demo folder and source the setup script in bash.
   ```
   bash
   source setup.bashrc
   ```

5. Run formal analysis with `make prove`.

6. View results (fired assertions) with `make gui`. Highly recommended to use
   a VNC desktop to interact with the Questa GUI.


Please see the `README.md` in each demo folder for detailed instructions.


## Deployment

We detail how to deploy SQED + SSS on a new design below using the Questa
toolchain step-by-step.

Most of the designer effort is spent in the following tasks:
- Specifying the ISA format for the `sqed-generator` and modifying the output
  as needed to work on your design
- Wiring up the QED Module to the design
- Writing the formal tool directives and properties to properly constrain
  the design for useful analysis.

### Step 1: Create the Recommended Directory Structure
Please review the directory structure details in the `demo_template/README.md`.
You can directly use the template as the starting point for deploying on a new
design.

`cp -r demo_template/ [DESIGN NAME]_demo/`

You should copy the unaltered version of the source design files into your
demo directory. Generally you will want to specify a certain commit hash
as a snapshot of the design you are verifying to ensure repeatability.
This can be easily done using git's submodule system. For example, the `cva6`
source files can be added to the `cva6_demo/` with the following:
```
# this is ran from the top level, sqed_sss/
git submodule add https://github.com/openhwgroup/cva6.git demos/cva6_demo/cva6
```

You can optionally enter the repo and checkout a particular
commit, which will be preserved when committing changes in `sqed_sss/`. 

### Step 2: Generate the QED Module
Used the [sqed-generator](https://github.com/upscale-project/sqed-generator)
to generate the proper files for the `qed/` directory. Be sure to include
the design-independent QED files to place in the `qed/` directory.

Please follow the instructions in the repo for properly specifying ISA
format files and generating the required files.

Keep in mind that you can reuse format files if the ISA is the same.

### Step 3: Specify the source files needed in the design file list
Add the paths to the source files / modules needed to instantiate the full
design in
```
*_demo/design/design.flist
```

There are three main groups of files:
1. Unmodified modules linking into the source repo directly
2. Modified or custom modules stored in `design/` directly
3. QED modules

Please see `steelcore_demo/design/design.flist` for an example.

Notice that lines in the unmodified modules group are commented out
if they are overridden by a modified or custom source file in the second group.

Be sure to include the `design_top` top level module described below. This
will likely be a custom source file you will need to create yourself.

QED modules should be the same across the demos.

Any `include` statements in files may need to be edited with full paths.


### Step 4: Wire Up the QED Module
In the module which instantiates the top-level pipeline, edit the design
to instantiate the QED module.

![QED Module Block Diagram](../images/qed_module_diagram.png)

Generally this occurs in the following steps:

1. Instantiate the `qed` module in the pipeline
2. Disconnect the instruction signal at starting at the decode stage.
3. Connect the `qed_ifu_instruction` from the QED module to the decode stage
4. Ensure that `vld_out` is properly handled in the design
5. Add logic for tracking the committed number of instructions in the design.
6. Add logic for tracking when Symbolic-In-Flight (SIF) instructions have
   committed.

This will require editing source files, such as the top-level pipeline.
Any modified source files should be copied into `design/` and the path should
be updated accordingly in `design/design.flist`.
This allows users / designers to quickly see which files have been edited and
which files are untouched. Any differences can be quickly spotted using
tools such as `vimdiff`, e.g.
```
vimdiff source_repo/src/original_file.v design/modified_file.v
```

### Step 5: Create the `design_top` Module
Wrap the top-level pipeline module in a `design_top` module in
`design/design_top.v` which exposes only a clock and reset for inputs.
All other I/O into the pipeline must be handled accordingly.
If the design comes standalone as a processor core only, without memory, a
memory can be instantiated here and connected properly.

### Step 6: Specify Directives and Initialization
In `formal/directives.tcl`, specify the following:

1. Clock properties (frequency)
2. Reset properties (typically tied to deasserted for SSS)
3. Cutpoints

Cutpoints are signals which the formal tool treats as inputs over time.
Typically we should have two cutpoints for SQED + SSS -
the instruction signal and the `exec_dup` signal.

You will also need to change the `$default_clock` in `formal.init` to match
the clock name in the design.

### Step 7: Specify Formal Constraints
In `formal/*_constraints.sv` add assertions and assumptions to constrain and
verify the design.

There are four broad classes of constraints needed by default:

1. `formal/initial_constraints.sv` constrain certain registers in the design to
   be initialized to certain values. This is needed since registers are not
   reset or initialized by default due to the nature of symbolic initialization.
   However, we need to initialize certain "meta-signals" such as the registers
   used in the qed modules or commit tracking logic to properly deploy the
   technique.

2. `formal/register_constraints.sv` constrains the register file to be consistent
   at T_C and asserts that the register file is QED consistent when appropriate

3. `formal/memory_constraints.sv` constrains the memory to be consistent
   at T_C and asserts that the memory is QED consistent when appropriate

4. `qed/inst_constraints.sv` constraints instructions to be valid.
   This is located in the `qed/` folder because it is automatically
   generated by the `sqed-generator`.

### Step 8: Bind
In `formal/formal_bind.sv`, bind the proper signals in `*_constraints.sv`
to the design's signals. E.g. binding the registers we are checking for QED
consistency to the register file in `register_constraints.sv`. 

### Step 9: Iteration Until Bug Free
Run `make prove` and see if any assertions fire.
Use `make gui` to investigate why these assertions failed.
Check if the cause is a true bug or trojan, or if it is a mistake in deployment.
You may need to add extra constraints or modify the design.


## Tips

1. Begin with `register_constraints.sv` and `inst_constraints.sv` bound only.
   Change the instructions issued to be `NOP`s only in `inst_constraints.sv`
   This will allow you to quickly identify mistakes in deploying the technique
   Slowly allow more instructions and add in `memory_constraints.sv` until
   the full ISA is being used and all architectural state is being evaluated.
