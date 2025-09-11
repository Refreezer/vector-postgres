# Connecting to Ollama from n8n

This guide explains how to connect to Ollama LLM service from n8n workflows.

## Setup

1. Make sure no local Ollama instance is running on your machine:
   ```
   ./stop-local-ollama.sh
   ```

2. Start all services and automatically download the Llama 3.2 model:
   ```
   ./setup-llama.sh
   ```

   The Ollama container will automatically download the Llama 3.2 model if it's not already installed. This may take a few minutes on the first run.

## Connecting in n8n

1. Open n8n in your browser: http://localhost:5678

2. Create a new workflow

3. Add an "HTTP Request" node:
   - Method: POST
   - URL: http://vector-ollama:11434/api/generate
   - Authentication: None
   - Request Format: JSON
   - JSON/RAW Parameters:
     ```json
     {
       "model": "llama3.2",
       "prompt": "Hello, how are you?",
       "stream": false
     }
     ```

4. Connect this node to your workflow and execute it

## Troubleshooting

If you're still having connection issues:

1. Verify both containers are running:
   ```
   docker-compose ps
   ```

2. Check Ollama logs:
   ```
   docker-compose logs ollama
   ```

3. Make sure the Llama model is downloaded:
   ```
   docker exec vector-ollama ollama list
   ```

4. Test the connection from n8n container:
   ```
   docker exec vector-n8n curl http://vector-ollama:11434/api/generate -d '{"model":"llama3.2","prompt":"test"}'
   ```

5. If the model isn't downloaded yet, run:
   ```
   docker exec vector-ollama ollama pull llama3.2
   ```

## Using in n8n HTTP Request Node

When creating your workflow in n8n, use these settings for the HTTP Request node:

- URL: `http://vector-ollama:11434/api/generate`
- Method: POST
- Request Body:
  ```json
  {
    "model": "llama3.2",
    "prompt": "{{$json.prompt}}",
    "stream": false
  }
  ```

This will allow you to pass the prompt from previous nodes in your workflow.