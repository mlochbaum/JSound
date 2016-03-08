CFLAGS = -O3 -fPIC
FLAGS = -shared
TARGET = libsynth.so

$(TARGET): synth.c
	cc synth.c $(CFLAGS) $(FLAGS) -o $(TARGET)
