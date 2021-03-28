# SQED + Symbolic Starting States on steelcore

A demonstration of Symbolic Quick Error Detection with Symbolic Starting States
(SQED + SSS) on Steel.

More details about how to set up an SQED + SSS demo can be found in the
top-level `sqed_sss/README.md`

## Design Overview
Steel is a RISC-V processor that implements RV32I + Zicsr instruction set.
It is a 3-stage pipeline, in-order, single issue core implemented in Verilog.
The design, ISA, and codebase is relatively simple to use.

We use the following commit snapshot of Steel for this demo:
[Steel - bc75810 oin Feb 15](https://github.com/rafaelcalcada/steel-core/commit/bc7581015cd35d0a7eabffcee2bfe04957a9d734)


## Toolchain
This codebase uses the Questa toolchain.


# Setup:
1. Run on rsg10.stanford.edu. Be sure to use ssh -Y to interact with the GUI
2. `source setup.bashrc`


## Usage:
- `make clean` to clean the workspace
- `make workspace` to create a workspace
- `make design` to initialize, patch, and compile the
   design under verification (DUV) with the QED module.
- `make compile` to compile the DUV with formal analysis
   directives
- `make prove` to run Questa Formal to analyze the DUV
- `make gui` to visualize the results of the formal analysis
  (you may need to manually open this using the output from `make prove`)
- `make all` to run all of the above in proper sequence


## Directory Structure and Details

The demo's directory structure is arranged as follows:
```
steelcore_demo/
|- README.md
|- Makefile
|- setup.bashrc
|- steelcore/
|- qed/
	 |- qed.v
	 |- qed_decoder.v
	 |- qed_i_cache.v
	 |- qed_instruction_mux.v
	 |- modify_instruction.v
	 |- inst_constraint.sv
|- patches/
	 |- patch.sh
	 |- wire_up/
	 |- optimization/
	 |- fix/
|- design/
	 |- design.flist
	 |- design_top.v
	 |- *.v, *.vh
|- formal/
	 |- formal.flist
	 |- formal_spec.sv
	 |- formal_bind.sv
	 |- formal.init
	 |- directives.tcl
```

- `Makefile` contains various Questa toolchain commands to faciliate the demo.
   See further details in the [Usage](#usage) section

- `setup.bashrc` contains environment variables needed to run the Questa
   toolchain. This contains paths that are specific to the RSG cluster.

- `steelcore/` is a directory containing an unaltered version of the design
   under verification. Please see [Design Overview](#design overview) for
   the exact commit hash.

- `qed/` is a directory containing the QED module and its supporting files.
   More details can be found in [QED](#qed)

- `patches/` is a directory containing files which facilitate the wire-up of
   the QED module to the design, various optimizations for run-time performance
   of formal analysis, and any bug fixes for found bugs.
   More details can be found in [Patches](#patches)

- `design/` is a directory that contains the patched version of the design
   under verification ready for formal analysis.
   More details can be found in [Design](#design)

- `formal/` is a directory that contains the properties, directives, and
   supplemental files for the formal tool and formal analysis.
   More details can be found in [Formal](#formal)


### QED
The `qed/` directory and files contain the QED module and its supporting files.

```
|- qed/
	 |- qed.v
	 |- qed_decoder.v
	 |- qed_i_cache.v
	 |- qed_instruction_mux.v
	 |- modify_instruction.v
	 |- inst_constraint.sv
```

- `qed.v` is the top level QED module which is instantiated in the DUV.
  The designer must wire up the module to the proper signals in the DUV,
  further details can be found in [Patches](#patches)

- `qed_decoder.v` decodes input instruction bitfields into meaningful signals
   (usually as single-bit wires) for use in `modify_instruction.v`.

- `qed_i_cache.v` buffers input original instructions. The cache enqueues new
   instructions and dequeues instructions that have been properly duplicated and
   sent to the rest of the processor pipeline.

- `qed_instruction_mux.v` multiplexes between original and QED-duplicate
   instructions

- `modify_instruction.v` transforms original instructions into QED-duplicates.

- `inst_constraint.sv` contain assumptions that constrain the input signal
   to be valid instructions only

The `qed/` files are ISA and processor-design dependent, and generally will
need to be generated and modified for deploying to new designs.

The `qed/` files can be automatically generated with the
[sqed-generator](https://github.com/upscale-project/sqed-generator).

As a designer, you will need to specify the ISA Format file for the tool
along with any other special constraints to create a new QED module.

### Patches
The `patches/` directory contains files which wire-up the QED module to the
DUV, optimize the DUV for formal analysis runtime, and fixes foung bugs in the
DUV.

```
|- patches/
	 |- patch.sh
	 |- wire_up/
	 |- optimization/
	 |- fix/
```

- `patch.sh` - Script which applies the patches to the original design

- `wire-up/` - Patches to wire up the QED module to the DUV

- `optimization/` - Patches which optimize the DUV for run-time performance
   of the formal analysis

- `fix/` - Patches which fix found bugs in the DUV

Our recommended workflow recommends copying the relevant design files from the
original design directory into the `patches/` directory and edit them directly.
They can then use `patch.sh` to copy the file into `design`.
This allows a faster iteration loop than creating patch files.

After finishing the deployment, the designer can then create patch files
and apply them with the `patch` tool to better preserve transparency of
changes to the original design.

For example, in order to wire-up the QED module, we copy the top level pipeline
from the original design directory into the `patches/` directory and
instantiate the QED module along with its supporting signals and logic in the
file. We then use the `patch.sh` script to simply `cp` this file into `design`
during `make design`. After we are sure wire-up is correct, we can export
the diffs as a patch file and only save the patch file in `patches/wire-up/`.

### Design
The `design/` directory contains the patched design-under-verification (DUV)
files ready for formal analysis.

```
|- design/
	 |- design.flist
	 |- design_top.v
	 |- *.v, *.vh
```

There are two files of particular note:
- `design.flist` is a file list which details the DUV files needed for
   compilation. This requires a file path relative to the `Makefile` location.

- `design_top.v` is the top-level module wrapper for formal analysis.
   This wrapper typically only exposes a clock and reset as inputs.
   Any irrelevant input signals into the design are properly terminated.
   If the design comes standalone as a processor core only, without memory,
   a memory can be instantiated here and connected properly.

### Formal
The `formal` directory contains formal properties and tool directives for
the formal tool to apply to the design.

```
|- formal/
	 |- formal.flist
	 |- formal_spec.sv
	 |- formal_bind.sv
	 |- formal.init
	 |- directives.tcl
```

- `formal.flist` is a file list of the relevant formal properties.

- `formal_spec.sv` contains the formal property specifications for our design.
   This typically contains any assumptions about initial state, our QED
   consistency check, and constraints on valid instructions.

- `formal_bind.sv` contains signal binding directives for Questa Formal
   This typically binds the registers we are examining for QED consistency
   checking to the register file.

- `formal.init` contains the initialization directives for Questa Formal

- `directives.tcl` contains the directives for Questa Formal analysis.
   In this file we typically specify properties of the clock and reset,
   as well as detail our "cutpoints" for the formal tool to treat as inputs
   over time. Typically we should have two cutpoints for SQED + SSS - 
   the instruction signal and the `exec_dup` signal.
