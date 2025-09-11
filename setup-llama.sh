#!/bin/bash

echo "Setting up Llama 3.2 locally with Ollama..."

# First, make sure no local Ollama instance is running
echo "Checking for local Ollama instances..."
./stop-local-ollama.sh

# Start the Docker Compose services
echo "Starting all Docker services..."
docker compose up -d

# Wait for services to be ready
echo "Waiting for services to start..."
echo "The Ollama container will automatically download the Llama 3.2 model if needed."
echo "This may take a few minutes for the first run."

# Wait for healthcheck to pass
echo "Waiting for Ollama to be ready..."
until docker compose ps ollama | grep -q "(healthy)"; do
  echo "Waiting for Ollama to become healthy..."
  sleep 5
done

# Verify the model is available
echo "Verifying Llama 3.2 is available..."
docker exec vector-ollama ollama list

# Test connectivity between n8n and Ollama
echo "Testing connectivity between n8n and Ollama..."
docker exec vector-n8n curl -s http://vector-ollama:11434/api/version
if [ $? -eq 0 ]; then
    echo "✅ n8n can connect to Ollama successfully!"
else
    echo "❌ Connection test failed. Please check the network configuration."
    echo "Trying to diagnose the issue..."
    
    echo "Checking if Ollama is running:"
    docker ps | grep vector-ollama
    
    echo "Checking Ollama logs:"
    docker logs vector-ollama --tail 10
    
    echo "Checking n8n logs:"
    docker logs vector-n8n --tail 10
fi

echo "Setup complete! Llama 3.2 is now available locally."
echo ""
echo "You can now:"
echo "1. Access Ollama API at: http://localhost:11434"
echo "2. Run Llama 3.2 interactively: docker exec -it vector-ollama ollama run llama3.2"
echo "3. Use the API endpoint: curl http://localhost:11434/api/generate -d '{\"model\": \"llama3.2\", \"prompt\": \"Hello!\"}'"
echo "4. Connect from n8n at: http://localhost:5678"
echo ""
echo "For detailed instructions on connecting n8n to Ollama, see the n8n-ollama-guide.md file."