import asyncio
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def main():
    server_params = StdioServerParameters(
        command="python",
        args=["/Users/justinoconnor/Code/semantic-kernel-with-mcp/documentation/server.py"],  # Replace with your server script path
        env=None
    )
    async with stdio_client(server_params) as (stdio, write):
        session = ClientSession(stdio, write)
        await session.initialize()
        # Example: List available tools
        response = await session.list_tools()
        print("Available tools:", [tool.name for tool in response.tools])
        # Implement further interactions as needed

asyncio.run(main())
