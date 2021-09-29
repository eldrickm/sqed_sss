.PHONY: workspace design compile prove clean all

OUT_DIR = output

workspace:
	echo "Setting Up Workspace"
	${VLIB} work
	${VMAP} work work

design: workspace
	echo "Initializing Ridecore Design"
	mkdir $(OUT_DIR)
	${VLOG} +define+FORMAL_TOOL +define+NOINITMEM topsim.v ridecore_checker_bind.sv ridecore_checker.sv  -f ./ridecore.flist -l $(OUT_DIR)/vlog.rpt

compile: design
	echo "Compiling Ridecore Design"
	qformal -c -od $(OUT_DIR) -do "\
		do directives.tcl; \
		formal compile -d top  -cuname ridecore_checker_bind -target_cover_statements ; \
		exit"

prove: compile
	echo "Proving Ridecore Design"
	qformal -c -od $(OUT_DIR) -do "\
		formal load db $(OUT_DIR)/formal_compile.db; \
		formal verify -init test.init ; \
		exit"

gui:
	echo "Launching GUI"
	qverify $(OUT_DIR)/formal_verify.db

clean:
	echo "Cleaning Repo"
	qformal_clean
	\rm -rf work
	\rm -f modelsim.ini
	\rm -f visualizer.log
	\rm -rf results
	\rm -rf $(OUT_DIR)

all: clean workspace design compile prove gui
