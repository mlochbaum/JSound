CFLAGS = -O3 -fPIC -ffast-math -march=native
FLAGS = -shared
TARGET = libsynth.so

$(TARGET): synth.c
	cc synth.c $(CFLAGS) $(FLAGS) -o $(TARGET)
