NESASM=tools/NESASM.EXE 
EMU=fceux
TILER=tools/NesTiler.exe
TEXT_CONVERTER=tools/TextConverter.exe
SOURCE=input_test.asm
EXECUTABLE=input_test.nes
BG_IMAGE=bg.png
BITS_IMAGE=bits.png

BG_PATTERN=bg_pattern_table.bin
BG_NAME_TABLE=bg_name_table.bin
BG_ATTR_TABLE=bg_attr_table.bin
BITS_PATTERN=bits_pattern_table.bin
PALETTE0=palette0.bin
PALETTE1=palette1.bin

all: $(EXECUTABLE)

build: $(EXECUTABLE)

$(EXECUTABLE): $(SOURCE) $(BG_PATTERN) $(BG_NAME_TABLE) $(BITS_PATTERN) $(PALETTE0) $(PALETTE1)
	rm -f $(EXECUTABLE)
	$(NESASM) $(SOURCE) -o $(EXECUTABLE) --symbols=$(EXECUTABLE) -iWss

clean:
	rm -f $(EXECUTABLE) *.lst *.nl *.bin

run: $(EXECUTABLE)
	$(EMU) $(EXECUTABLE)

$(BG_PATTERN) $(BG_NAME_TABLE) $(BITS_PATTERN) $(PALETTE0) $(PALETTE1): $(BG_IMAGE) $(BITS_IMAGE)
	$(TILER) -i0 $(BG_IMAGE) -i1 $(BITS_IMAGE) --enable-palettes 0,1 \
  --out-pattern-table0 $(BG_PATTERN) \
  --out-pattern-table1 $(BITS_PATTERN) \
  --out-name-table0 $(BG_NAME_TABLE) \
  --out-attribute-table0 $(BG_ATTR_TABLE) \
  --bgcolor \#FFFFFF --palette1 \#0000FF \
  --out-palette0 $(PALETTE0) --out-palette1 $(PALETTE1)
  
.PHONY: clean
