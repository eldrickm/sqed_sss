#!/bin/sh

qformal -c -od Output_Results -do "\
    do directives.tcl; \
    formal compile -d toppipe  -cuname vscale_checker_bind -target_cover_statements ; \
    exit"

