CC=gcc
CFLAGS=-Wall -Wextra -Werror -std=c99 -pedantic -g

%: %.c
	$(CC) $(CFLAGS) -o $@ $<
	./$@

clean:
	rm -f p1 p2 p3 p4
