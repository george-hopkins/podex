HEADER=bdm12_flash912d60a.h

blesk.asm: blesk.s
	./gas2mgtek.pl < blesk.s > blesk.asm 2> /dev/null
	../mgtek/asm12 -ls -case blesk.asm

header: blesk.asm
	echo \#ifndef BDM12_PROGRAMFLASH_SIZE > $(HEADER)
	grep ^BDM blesk.lst | perl -e 'while(<>){ s/^(\S+\s+)(.*)$$/\#define \1\(0x\2 - 0x800\)/; print $$_;}' >> $(HEADER) 2>/dev/null
	./mpconvert < blesk.s19 >> $(HEADER)
	echo \#define eraseflash programflash >> $(HEADER)
	echo \#define BDM12_ERASEFLASH_SIZE BDM12_PROGRAMFLASH_SIZE >> $(HEADER)
	echo \#endif >> $(HEADER)
