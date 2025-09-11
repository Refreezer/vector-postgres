#!/bin/bash

echo "Stopping locally running Ollama service..."

# For macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Check if Ollama is running
    if pgrep -x "ollama" > /dev/null; then
        echo "Found Ollama process running on macOS"
        echo "Stopping Ollama service..."
        killall ollama
        
        # Wait a moment
        sleep 2
        
        # Check if it's still running and force kill if necessary
        if pgrep -x "ollama" > /dev/null; then
            echo "Ollama is still running. Trying force kill..."
            killall -9 ollama
        fi
        
        echo "Ollama stopped successfully"
    else
        echo "No Ollama process found running on macOS"
    fi
    
    # Check for Docker containers using Ollama
    echo "Checking for Docker containers using port 11434..."
    if docker ps | grep -q "ollama"; then
        echo "Found Docker container running Ollama. Stopping it..."
        docker stop $(docker ps | grep ollama | awk '{print $1}')
    fi

# For Linux
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Check if Ollama is running as a systemd service
    if systemctl is-active --quiet ollama; then
        echo "Stopping Ollama systemd service..."
        sudo systemctl stop ollama
        echo "Ollama service stopped"
    # Check if Ollama is running as a process
    elif pgrep -x "ollama" > /dev/null; then
        echo "Found Ollama process running on Linux"
        echo "Stopping Ollama process..."
        killall ollama
        echo "Ollama stopped successfully"
    else
        echo "No Ollama process found running on Linux"
    fi

# For Windows (if using WSL or Git Bash)
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "On Windows, you can stop Ollama by:"
    echo "1. Finding Ollama in the system tray"
    echo "2. Right-clicking on the Ollama icon"
    echo "3. Selecting 'Quit Ollama'"
    echo ""
    echo "Or open Task Manager, find Ollama, and end the task"
fi

# Check if port 11434 is still in use
echo "Checking if port 11434 is still in use..."
if command -v lsof &> /dev/null; then
    if lsof -i :11434 > /dev/null; then
        echo "Warning: Port 11434 is still in use by another process"
        echo "Process using port 11434:"
        lsof -i :11434
        
        echo ""
        echo "To forcefully kill ALL processes using port 11434, run:"
        echo "sudo kill -9 \$(lsof -t -i:11434)"
        echo ""
        echo "Or to kill specific process by PID:"
        echo "kill -9 [PID]"
    else
        echo "Port 11434 is now free"
    fi
elif command -v netstat &> /dev/null; then
    if netstat -tuln | grep 11434 > /dev/null; then
        echo "Warning: Port 11434 is still in use by another process"
        echo "Process using port 11434:"
        netstat -tuln | grep 11434
    else
        echo "Port 11434 is now free"
    fi
else
    echo "Cannot check port status - neither lsof nor netstat is available"
fi

echo ""
echo "After stopping Ollama, you can run your Docker setup with:"
echo "docker-compose up -d"