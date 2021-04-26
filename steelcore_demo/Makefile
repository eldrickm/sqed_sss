.PHONY: workspace design compile prove clean all

OUT_DIR = output
PATCH_DIR = output
DESIGN_DIR = design
FORMAL_DIR = formal

workspace: clean
	@echo "========== Intializing Questa Workspace =========="
	${VLIB} work
	${VMAP} work work
	mkdir -p $(OUT_DIR)

design: workspace
	@echo "========== Compiling Design =========="
	./patches/patch.sh
	${VLOG} -f $(DESIGN_DIR)/design.flist -f $(FORMAL_DIR)/formal.flist -l $(OUT_DIR)/vlog.rpt

compile: design
	@echo "========== Compiling Formal Properties =========="
	qformal -c -od $(OUT_DIR) -do "\
		do $(FORMAL_DIR)/directives.tcl; \
    	formal compile -d design_top -cuname formal_bind -target_cover_statements; \
    	exit"

prove: compile
	@echo "========== Proving Formal Properties =========="
	qformal -c -od $(OUT_DIR) -do "\
		formal load db $(OUT_DIR)/formal_compile.db; \
		formal verify -init $(FORMAL_DIR)/formal.init -rtl_init_values; \
		exit"

gui:
	@echo "========== Launching Questa GUI =========="
	qverify $(OUT_DIR)/formal_verify.db

clean:
	@echo "========== Cleaning Questa Workspace =========="
	qformal_clean
	\rm -rf work
	\rm -f modelsim.ini
	\rm -f visualizer.*
	\rm -f visualizerCore.ses
	\rm -rf results
	\rm -rf hnl_const_prop.rpt
	\rm -rf transcript
	\rm -rf .qverify_ui_local_prefs
	\rm -rf .visualizer/
	\rm -rf $(OUT_DIR)
	\rm -rf $(DESIGN_DIR)/*.v
	\rm -rf $(DESIGN_DIR)/*.vh
	\rm -rf $(DESIGN_DIR)/*.flist

all: clean workspace design compile prove gui
