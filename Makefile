# Nome del file eseguibile
TARGET = app.out

# Opzioni di compilazione
CFLAGS = -Wall
LDFLAGS = -lpq

all:
	gcc query.c -o $(TARGET) $(CFLAGS) $(LDFLAGS)

clean:
	rm -f $(TARGET)