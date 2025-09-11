#!/bin/sh

# Wait for Ollama service to be ready
echo "Waiting for Ollama service to start..."
until curl -s http://ollama:11434/api/version > /dev/null 2>&1; do
  echo "Waiting for Ollama API to be available..."
  sleep 2
done

echo "Ollama service is ready!"

# Check if Llama 3.2 model is already installed
MODEL_LIST=$(curl -s http://ollama:11434/api/tags)
if echo "$MODEL_LIST" | grep -q "llama3.2"; then
  echo "Llama 3.2 model is already installed."
else
  echo "Pulling Llama 3.2 model (this may take a while)..."
  curl -X POST http://ollama:11434/api/pull -d '{"name": "llama3.2"}'
  echo "Llama 3.2 model has been installed successfully!"
fi

echo "Initialization complete!"