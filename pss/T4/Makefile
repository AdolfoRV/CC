# Para revisar las opciones de compilacion y ejecucion,
# ingrese en el terminal el comando: make
#
#

PROB=definir

SRCS= $(PROB).c
HDRS= 

SHELL=bash -o pipefail

INCLUDE=
CFLAGS=-Wall -Werror -pedantic -std=c18 -Wno-unused-function $(INCLUDE)
LDLIBS=-lm
ARCH=$(shell arch)

MAK=make --no-print-directory

readme:
	@less README.txt

revisar:
	$(MAK) PROB=revisar SRCS="revisar.c pss.c" HDRS=pss.h revisar.bin
	@echo
	./revisar.bin defs.dicc
	@echo
	@echo "Estudie este programa ejecutandolo bajo ddd con este comando:"
	@echo "make revisar.ddd"

revisar.ddd:
	$(MAK) PROB=revisar SRCS="revisar.c pss.c" HDRS=pss.h revisar.bin-g
	ddd revisar.bin-g &
	@echo "Coloque un breakpoint con: b main"
	@echo "Ejecute el programa con: r defs.dicc"
	@echo "Ejecute paso a paso con el boton next"

revisar.san:
	$(MAK) PROB=revisar SRCS="revisar.c pss.c" HDRS=pss.h revisar.bin-san
	./revisar.bin-san defs.dicc

bench:
	$(MAK) PROB=bench bench.bin-san

$(PROB).bin $(PROB).bin-g $(PROB).bin-san: $(SRCS) $(HDRS)

run-san: $(PROB).bin-san
	@if grep -P '\t' $(PROB).c ; then echo "Su archivo $(PROB).c contiene tabs" ; echo "Reemplacelos por espacios en blanco con el comando expand!" ; echo "No olvide revisar su indentacion"; false ; else true; fi
	bash test-$(PROB).sh $(PROB).bin-san

run-g: $(PROB).bin-g
	bash test-$(PROB).sh $(PROB).bin-g

prof.ref: $(PROB).bin
	cp $(PROB).bin prof.ref-$(ARCH)
	strip prof.ref-$(ARCH)

run: $(PROB).bin
	bash test-$(PROB).sh $(PROB).bin
	@rm -f big_prof.dicc big_alum.dicc
	@touch big_prof.dicc big_alum.dicc
	$(MAK) PROB=bench bench.bin
	./bench.bin ./prof.ref-$(ARCH) ./$(PROB).bin

ddd: $(PROB).ddd

ddd-san: $(PROB).ddd-san

zip:
	@if grep -P '\t' $(PROB).c ; then echo "Su archivo $(PROB).c contiene tabs.  Reemplacelos por espacios en blanco!" ; false ; else true; fi
	@rm -f resultados.txt $(PROB).zip
	@echo "Sistema operativo utilizado" > resultados.txt
	@uname -a >> resultados.txt
	@cat resultados.txt
	@echo ==== run-san ==== | tee -a resultados.txt
	@$(MAK) -B run-san | tee -a resultados.txt
	@echo ==== run-g ==== | tee -a resultados.txt
	@$(MAK) -B run-g | tee -a resultados.txt
	@echo ==== run ==== | tee -a resultados.txt
	@$(MAK) -B run | tee -a resultados.txt
	@echo ==== zip ====
	zip -r $(PROB).zip resultados.txt $(PROB).c
	@echo "Entregue por u-cursos el archivo $(PROB).zip"
	@echo "Descargue de u-cursos lo que entrego, descomprimalo y revise"
	@echo "que esta su ultima version de $(PROB).c"

%.bin: %.c
	gcc -O -DOPT=1 $(CFLAGS) $(SRCS) $(LDLIBS) -o $@

%.bin-g: %.c
	gcc -g $(CFLAGS) $(SRCS) $(LDLIBS) -o $@

%.bin-san: %.c
	gcc -g -DSAN=1 -fsanitize=address -fsanitize=undefined $(CFLAGS) $(SRCS) $(LDLIBS) -o $@

%.ddd: %.bin-g
	ddd $(*F).bin-g &

%.ddd-san: %.bin-san
	ddd $(*F).bin-san &

clean:
	rm -rf *.o *.log *.bin* core $(PROB).zip resultados.txt bin obj err-ref.txt err.txt raw-std-ref.txt raw-std.txt std-ref.txt std.txt big_prof.dicc big_alum.dicc res.txt
