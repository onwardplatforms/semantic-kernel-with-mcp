# Model Context Protocol with FastAPI Documentation Service

This project demonstrates how to use the Model Context Protocol (MCP) Python SDK to create a documentation search service, exposing it through a FastAPI web API.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/semantic-kernel-with-mcp.git
cd semantic-kernel-with-mcp

# Set up the project (creates virtual env, installs dependencies, sets up .env)
make boot

# Start all components
make start

# To run tests
make test

# To stop all components
make stop
```

## Project Overview

The application allows users to search for documentation from popular ML/AI libraries (LangChain, LlamaIndex, and OpenAI) via a simple REST API. It leverages:

- **Model Context Protocol (MCP)**: A protocol for AI assistants to interact with external tools
- **FastAPI**: A modern, fast web framework for building APIs
- **Google Search API**: To find relevant documentation pages
- **BeautifulSoup**: To extract text content from web pages

## Project Structure

```
├── .env                # Environment variables (API keys)
├── .env.sample         # Sample environment file
├── .python-version     # Python version configuration for pyenv
├── .venv               # Python virtual environment
├── Makefile            # Automation for common tasks
├── README.md           # Project documentation
├── api.py              # FastAPI application
├── client.py           # MCP client example
├── requirements.txt    # Python dependencies
├── server.py           # MCP server with documentation tool
└── test_api.py         # Test script for the API
```

## Using the Makefile

The Makefile provides several useful commands to simplify development and usage:

- `make boot` - Set up everything (virtual env, dependencies, .env file)
- `make start-server` - Start the MCP server
- `make start-client` - Run the MCP client
- `make start-api` - Start the FastAPI server
- `make start` - Start all components
- `make stop` - Stop all running processes
- `make restart` - Restart everything (stops and starts)
- `make test` - Run the test script
- `make clean` - Clean up cache files
- `make help` - Show available commands

## API Documentation

Access the interactive API documentation at http://localhost:8000/docs once the server is running.

The API provides the following endpoints:

1. `GET /` - Health check
2. `GET /tools` - List available documentation tools
3. `POST /docs` - Search for documentation based on query and library

## Extending with More Components

The project is designed to be easily extensible. When adding new components:

1. **Adding new ports**: Edit the Makefile to add new port definitions:
   ```makefile
   # Ports configuration
   API_PORT := 8000
   UI_PORT := 3000  # Uncomment when adding UI
   
   # Define all ports in use (for stop command)
   PORTS := $(API_PORT) $(UI_PORT)
   ```

2. The `stop` command automatically handles all ports in the PORTS list, making it easy to add new services.

3. **Example: Adding a UI**:
   - Uncomment the UI_PORT line in the Makefile
   - Add a new make target for starting the UI
   - Update the start target to launch the UI component as well

## How It Works

### The MCP Server (server.py)

The MCP server exposes a documentation search tool that:

1. Takes a query and library name as input
2. Performs a web search using the Serper API (Google Search API)
3. Fetches the content of the top results
4. Returns the extracted text

```python
@mcp.tool()  
async def get_docs(query: str, library: str):
  """
  Search the latest docs for a given query and library.
  Supports langchain, openai, and llama-index.
  """
  if library not in docs_urls:
    raise ValueError(f"Library {library} not supported by this tool")
  
  query = f"site:{docs_urls[library]} {query}"
  results = await search_web(query)
  if len(results["organic"]) == 0:
    return "No results found"
  
  text = ""
  for result in results["organic"]:
    text += await fetch_url(result["link"])
  return text
```

### The FastAPI Application (api.py)

The FastAPI application provides a REST API interface to the documentation search functionality:

1. It imports and calls the `get_docs` function from the server module directly
2. It exposes three endpoints:
   - GET `/` - Simple health check
   - GET `/tools` - Lists available documentation tools
   - POST `/docs` - Searches for documentation based on query and library

### Testing the API

Test the API using curl:

```bash
# Health check
curl http://localhost:8000/

# List available tools
curl http://localhost:8000/tools

# Search for documentation
curl -X POST http://localhost:8000/docs \
  -H "Content-Type: application/json" \
  -d '{"query":"embeddings", "library":"langchain"}'
```

## Troubleshooting

### Port Already in Use

If you encounter port conflicts, the Makefile automatically attempts to resolve them. However, you can manually stop processes using:

```bash
make stop
```

### Python Version Issues

If you encounter Python version errors, make sure the version in `.python-version` matches an installed Python version:

```bash
# List installed Python versions
pyenv versions

# Update .python-version to match an installed version
echo "3.11.7" > .python-version
```

## Conclusion

This project demonstrates how to create a practical documentation search service using FastAPI, combining web search and content extraction capabilities. The API-first design makes it easy to integrate with other applications or build a frontend UI on top.

Feel free to use, modify, and extend this code for your own projects!
