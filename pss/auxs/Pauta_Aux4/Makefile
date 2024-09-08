CC=gcc
CFLAGS=-Wall -Wextra -Werror -std=c99 -pedantic -g

%: %.c
	gcc -o $@ $<
	./$@

p%: p%.o utils.o
	$(CC) $(CFLAGS) -o p$*.out p$*.o utils.o
	./$@.out

run-p%: p%
	./$^.out

clean:
	rm -f p1 p2
