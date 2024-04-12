# Use an official GCC runtime as a parent image
FROM gcc:latest

# Set the working directory in the container
WORKDIR /usr/src/myapp_io

# Copy the current directory contents into the container at /usr/src/myapp
COPY main.cpp main.cpp

# Compile your C++ program
RUN g++ -o myapp_io main.cpp

# Run the output program from the previous step
CMD ["./myapp_io"]