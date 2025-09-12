#!/bin/sh

# Start ollama server in the background
ollama serve &

# Save the PID of the ollama serve process
OLLAMA_PID=$!

# Wait for ollama to be ready
echo "Waiting for Ollama to start..."
sleep 10

# Pull the model
echo "Pulling llama3.2 model..."
ollama pull llama3.2

echo "Model pulled successfully!"

# Wait for the ollama serve process to keep the container running
wait $OLLAMA_PID