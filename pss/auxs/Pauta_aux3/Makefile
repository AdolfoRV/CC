CC=gcc
CFLAGS=-g -lm

ARGS=Hola

%: %.c
%: %.o

%.out: %.c
	$(CC)  $(CFLAGS)  $<  -o  $@ 

run-%: %.out
	./$*.out $(ARGS)

# Reglas especificas
all: p1 p2 p3 p4

p1: p1.out
p2: p2.out
p3: p3.out
p4: p4.out


clean:
	rm -rf *.o *.out
