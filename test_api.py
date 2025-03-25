import requests
import json

BASE_URL = "http://localhost:8000"

def test_list_tools():
    """Test the /tools endpoint"""
    response = requests.get(f"{BASE_URL}/tools")
    print("\n=== Available Tools ===")
    for tool in response.json():
        print(f"Tool: {tool['name']}")
        print(f"Description: {tool['description']}")
        print()
    
    return response.status_code == 200

def test_get_docs():
    """Test the /docs endpoint"""
    test_payloads = [
        {"query": "embeddings", "library": "langchain"},
        {"query": "vector database", "library": "llama-index"},
        {"query": "assistants", "library": "openai"}
    ]
    
    for i, payload in enumerate(test_payloads):
        print(f"\n=== Test {i+1}: {payload['library']} - {payload['query']} ===")
        
        try:
            response = requests.post(
                f"{BASE_URL}/docs",
                json=payload
            )
            
            if response.status_code == 200:
                result = response.json()
                # Print first 200 chars of the result
                print(f"Result preview: {result['result'][:200]}...")
                print(f"Status: SUCCESS (HTTP {response.status_code})")
            else:
                print(f"Status: FAILED (HTTP {response.status_code})")
                print(f"Error: {response.text}")
                
        except Exception as e:
            print(f"Error: {str(e)}")
    
if __name__ == "__main__":
    print("Testing Documentation API...")
    
    # Test tools endpoint
    if test_list_tools():
        print("\nTools endpoint test: SUCCESS")
    else:
        print("\nTools endpoint test: FAILED")
    
    # Test docs endpoint
    print("\nTesting docs endpoint...")
    test_get_docs()
    
    print("\nTests completed!") 