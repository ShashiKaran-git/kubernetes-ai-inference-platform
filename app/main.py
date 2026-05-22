from fastapi import FastAPI
from pydantic import BaseModel
from transformers import pipeline
import torch

app = FastAPI()

generator = pipeline(
    "text-generation",
    model="distilgpt2"
)

class PromptRequest(BaseModel):
    prompt: str

@app.get("/")
def home():
    return {"message": "AI Inference API Running"}

@app.post("/generate")
def generate_text(request: PromptRequest):

    result = generator(
        request.prompt,
        max_new_tokens=40,
        temperature=0.7,
        do_sample=True,
        truncation=True
    )
    return {
        "response": result[0]["generated_text"]
    }