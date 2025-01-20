from fastapi import FastAPI, HTTPException, BackgroundTasks
from pydantic import BaseModel
import subprocess
import requests
import os
import signal

app = FastAPI()

class StartModelRequest(BaseModel):
    model: str

class CompletionRequest(BaseModel):
    prompt: str
    n_predict: int

current_model = None
server_process = None

@app.get("/")
async def read_root():
    return {"message": "API is up and running!"}

@app.post("/start")
async def start_model(request: StartModelRequest, background_tasks: BackgroundTasks):
    global current_model, server_process
    if server_process:
        raise HTTPException(status_code=400, detail="Server is already running")

    current_model = request.model
    server_process = subprocess.Popen(["make", current_model], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    background_tasks.add_task(monitor_process, server_process)

    return {"message": f"Server started with model: {current_model}"}

@app.post("/stop")
async def stop_model():
    global server_process, current_model
    if not server_process:
        raise HTTPException(status_code=400, detail="Server is not running")

    server_process.send_signal(signal.SIGTERM)
    server_process.wait()
    server_process = None
    current_model = None

    return {"message": "Server stopped"}

@app.post("/test")
async def test_model():
    if not server_process:
        raise HTTPException(status_code=400, detail="Server is not running")

    result = subprocess.run(["make", "test"], capture_output=True, text=True)
    if result.returncode != 0:
        raise HTTPException(status_code=500, detail=f"Error testing server: {result.stderr}")

    return {"message": "Server tested successfully"}

@app.post("/completion")
async def completion(request: CompletionRequest):
    if not server_process:
        raise HTTPException(status_code=400, detail="Server is not running")

    response = requests.post(
        "http://localhost:8080/completion",
        json={"prompt": request.prompt, "n_predict": request.n_predict}
    )
    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail=response.text)

    return response.json()

def monitor_process(process):
    for line in process.stdout:
        print(line.decode(), end='')
    for line in process.stderr:
        print(line.decode(), end='')
    process.wait()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

