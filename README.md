# Symbolic Quick Error Detection + Symbolic Starting States

A collection of Symbolic Quick Error Detection + Symbolic Starting States
(SQED + SSS) demos on a variety of processor designs along with instructions on
how to deploy the technique, and supplemental resources concerning formal
proofs and case studies.


## Table of Contents

- [Quick Start](#Quick Start)
- [Overview](#Overview)
- [Resources](#Resources)
- [Contributors](#Contributors)


## Quick Start

Read `demos/README.md`


## Overview

The repo's directory structure is arranged as follows:

```
|- README.md
|- LICENSE-ACADEMIC
|- LICENSE-GOV
|- demos/
|- images/
|- papers/
|- presentations/
|- utilities/
```

- `README.md` is the document you are currently reading containing
   high-level information about the repo.

- `LICENSE-ACADEMIC` contains the Stanford Academic Use Software License
   Agreement

- `LICENSE-GOV` contains the Stanford Government Use Software License
   Agreement

- `demos/` contains demos of the SQED+SSS technique on a variety of processors.
   Further detailed information can be found in each processor design's
   directory, along with instructions to run the technique.

- `images/` contains figures and images related to this work

- `papers/` contains published papers and drafts related to this work

- `presentations/` contains slides and presentations related to this work

- `utilities/` contains helpful scripts related to this work


## Resources

- [sqed-generator](https://github.com/upscale-project/sqed-generator)
  automatically generates the QED module and related files used in this work.
  Eldrick Millares has a privately-maintained copy at
  [sqed-generator](https://github.com/eldrickm/sqed-generator.git) that fully
  specifies the RV32I instruction set.


## Contributors

- [@eldrickm](https://github.com/eldrickm)
- [@jackhumphries](https://github.com/jackhumphries)
