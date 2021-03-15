.PHONY: workspace design compile prove clean all

OUT_DIR = output

workspace:
	echo "Setting Up Workspace"
	${VLIB} work
	${VMAP} work work

design: workspace
	echo "Compiling Design"
	mkdir $(OUT_DIR)
	${VLOG} +define+FORMAL_TOOL +define+NOINITMEM +define+INITIALIZERO picorv32_qed.v picorv32_checker_bind.sv picorv32_checker.sv  -f ./picorv32.flist -l $(OUT_DIR)/vlog.rpt

compile: design
	echo "Compiling Design"
	qformal -c -od $(OUT_DIR) -do "\
   		do directives.tcl; \
    	formal compile -d picorv32 -cuname picorv32_checker_bind -target_cover_statements ; \
    	exit"

prove: compile
	echo "Proving Design"
	qformal -c -od $(OUT_DIR) -do "\
		formal load db $(OUT_DIR)/formal_compile.db; \
		formal verify -init test.init -rtl_init_values -effort unlimited ; \
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


# found in prove.sh~
#qverify -c -od Output_Results -do "\
#    formal load db Output_Results/formal_compile.db; \
#    formal verify -jobs 4 -engines 19  -init test.init -rtl_init_values -effort unlimited -timeout 24h ; \
#    exit"
