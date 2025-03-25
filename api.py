from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import asyncio
import os
import sys
import subprocess
from typing import List, Dict, Any, Optional

# Models
class DocRequest(BaseModel):
    query: str
    library: str

class DocResponse(BaseModel):
    result: str

# Create FastAPI app
app = FastAPI(title="Documentation API", description="API for retrieving library documentation")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

async def get_docs(query: str, library: str) -> str:
    """Call the get_docs function in server.py directly"""
    try:
        # Import the server module directly
        server_path = os.path.join(os.path.dirname(__file__), "server.py")
        sys.path.append(os.path.dirname(server_path))
        
        # Import the get_docs function from server.py
        from server import get_docs as server_get_docs
        
        # Call the function directly
        result = await server_get_docs(query=query, library=library)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error calling get_docs: {str(e)}")

@app.get("/tools", response_model=List[Dict[str, str]])
async def list_tools():
    """List available documentation tools"""
    return [
        {
            "name": "get_docs",
            "description": "Search the latest docs for a given query and library. Supports langchain, openai, and llama-index."
        }
    ]

@app.post("/docs", response_model=DocResponse)
async def get_documentation(request: DocRequest):
    """
    Get documentation for a specific library and query
    
    - **query**: The search query
    - **library**: Library to search (langchain, llama-index, or openai)
    """
    try:
        result = await get_docs(query=request.query, library=request.library)
        return DocResponse(result=result)
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/", response_model=Dict[str, str])
async def health_check():
    """Simple health check endpoint"""
    # Include port info in response
    port = os.environ.get("API_PORT", "8000")
    return {
        "status": "ok", 
        "message": f"Documentation API is running on port {port}"
    }

if __name__ == "__main__":
    import uvicorn
    
    # Get port from environment variable or use default
    port = int(os.environ.get("API_PORT", 8000))
    
    print(f"Starting API server on port {port}...")
    uvicorn.run(app, host="0.0.0.0", port=port) 