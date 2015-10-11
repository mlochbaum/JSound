CFLAGS = -fPIC
FLAGS = -shared
TARGET = libsynth.so

$(TARGET): synth.c
	cc synth.c $(CFLAGS) $(FLAGS) -o $(TARGET)
