# Utilities

- `decode_rv32i.py` interprets RV32I hex instructions into readable assembly.
   Most of the parsing logic is directly derived from the output of the
   [sqed-generator](https://github.com/upscale-project/sqed-generator).
   In order to use it, enter line-separated 32b hex instructions inside of
   `inst_list.txt` and run
   ```
   python decode_rv32i.py
   ```
