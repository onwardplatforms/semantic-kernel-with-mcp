# Makefile for MCP Documentation API

# Python executable
PYTHON := python
VENV_NAME := .venv
VENV_ACTIVATE := . $(VENV_NAME)/bin/activate

# Environment variables
ENV_FILE := .env
ENV_SAMPLE := .env.sample

# Ports configuration (easily extendable)
API_PORT := 8000
# UI_PORT := 3000  # Uncomment when adding UI
# Add more ports as needed for future components

# Define all ports in use (for stop command)
PORTS := $(API_PORT) # $(UI_PORT)  # Uncomment when adding UI

.PHONY: help boot stop start-server start-client start-api start restart test clean

help:
	@echo "Available commands:"
	@echo "  make boot          - Set up everything (env, dependencies, venv)"
	@echo "  make start-server  - Start the MCP server"
	@echo "  make start-client  - Run the MCP client"
	@echo "  make start-api     - Start the FastAPI server (port $(API_PORT))"
	@echo "  make start         - Start all components"
	@echo "  make stop          - Stop all running processes"
	@echo "  make restart       - Restart everything (stops and starts)"
	@echo "  make test          - Run the test script"
	@echo "  make clean         - Clean up cache files"

# Boot command - sets up environment, dependencies, and virtual env
boot:
	@echo "Setting up project..."
	
	@# Check for Python virtual environment
	@if [ ! -d "$(VENV_NAME)" ]; then \
		echo "Creating virtual environment..."; \
		python -m venv $(VENV_NAME); \
	else \
		echo "Virtual environment already exists."; \
	fi
	
	@# Set up .env file
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "Creating .env file..."; \
		if [ -f $(ENV_SAMPLE) ]; then \
			cp $(ENV_SAMPLE) $(ENV_FILE); \
			echo ".env file created from sample. Please update with your API keys."; \
		else \
			echo "SERPER_API_KEY=your_api_key_here" > $(ENV_FILE); \
			echo "API_PORT=8000" >> $(ENV_FILE); \
			echo ".env file created. Please update with your API keys."; \
		fi \
	else \
		echo ".env file already exists."; \
	fi
	
	@# Install dependencies
	@echo "Installing dependencies..."
	$(VENV_ACTIVATE) && pip install -r requirements.txt
	
	@echo "✅ Setup complete! You can now run 'make start' to start the application."

# Helper function to kill processes on the API port
_kill_api_port:
	@echo "Checking for processes using API port $(API_PORT)..."
	@lsof -i :$(API_PORT) || echo "No process found on port $(API_PORT)"
	@lsof -ti :$(API_PORT) | xargs kill -9 2>/dev/null || echo "No process to kill on port $(API_PORT)"

start-server:
	@echo "Starting MCP server..."
	$(PYTHON) server.py

start-client:
	@echo "Running MCP client..."
	$(PYTHON) client.py

start-api: _kill_api_port
	@echo "Starting FastAPI server on port $(API_PORT)..."
	API_PORT=$(API_PORT) $(PYTHON) api.py

start: _kill_api_port
	@echo "Starting all components..."
	@# Start API server in background
	API_PORT=$(API_PORT) $(PYTHON) api.py & echo $$! > .api.pid
	@echo "API server started in the background (PID: $$(cat .api.pid)) on port $(API_PORT)"
	@echo "To stop all processes, use: make stop"

stop:
	@echo "Stopping all project-related processes..."
	
	@# Stop any tracked processes by PID file
	@if [ -f .api.pid ]; then \
		echo "Stopping API server (PID: $$(cat .api.pid))..."; \
		kill $$(cat .api.pid) 2>/dev/null || echo "API server was not running"; \
		rm .api.pid; \
	fi
	
	@# Kill any processes using our configured ports
	@echo "Checking for processes using configured ports..."
	@for port in $(PORTS); do \
		echo "Checking port $$port..."; \
		lsof -ti :$$port | xargs kill -9 2>/dev/null || echo "No process found on port $$port"; \
	done
	
	@# Kill all python processes related to our main scripts
	@echo "Checking for other project-related Python processes..."
	@ps aux | grep "[p]ython.*api\.py" | awk '{print $$2}' | xargs kill -9 2>/dev/null || echo "No API processes found"
	@ps aux | grep "[p]ython.*server\.py" | awk '{print $$2}' | xargs kill -9 2>/dev/null || echo "No server processes found"
	@ps aux | grep "[p]ython.*client\.py" | awk '{print $$2}' | xargs kill -9 2>/dev/null || echo "No client processes found"
	
	@echo "All processes stopped."

restart: stop start
	@echo "Restart completed!"

test:
	@echo "Running API tests..."
	$(PYTHON) test_api.py

clean: stop
	@echo "Cleaning up..."
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*.pyd" -delete
	find . -type f -name ".coverage" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	find . -type d -name "*.egg" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	find . -type d -name ".coverage" -exec rm -rf {} +
	find . -type d -name "htmlcov" -exec rm -rf {} +
	find . -type d -name ".tox" -exec rm -rf {} +
	@echo "Cleanup complete!"

# Default target when just running 'make'
.DEFAULT_GOAL := help 