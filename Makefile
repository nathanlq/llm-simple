# Define the path to the models directory
MODELS_DIR = ../models

# Define the command to launch the llama-server
LLAMA_SERVER = llama-server -m

# Define the models and their aliases
gemma_model = gemma-2-9b-it-Q5_K_M.gguf
llama13b_model = llama-2-13b-chat.Q5_K_M.gguf
meta8b_model = Meta-Llama-3.1-8B-Instruct-Q5_K_M.gguf
ministral8b_model = Ministral-8B-Instruct-2410-Q5_K_M.gguf
qwen7b_model = Qwen2.5-7B-Instruct-Q5_K_M.gguf
solar10b_model = solar-10.7b-instruct-v1.0.Q5_K_M.gguf
starling7b_model = Starling-LM-7B-beta-Q5_K_M.gguf

# Define targets for each model
.PHONY: gemma llama13b meta8b ministral8b qwen7b solar10b starling7b test all api

gemma:
	@$(LLAMA_SERVER) $(MODELS_DIR)/$(gemma_model)

llama13b:
	@$(LLAMA_SERVER) $(MODELS_DIR)/$(llama13b_model)

meta8b:
	@$(LLAMA_SERVER) $(MODELS_DIR)/$(meta8b_model)

ministral8b:
	@$(LLAMA_SERVER) $(MODELS_DIR)/$(ministral8b_model)

qwen7b:
	@$(LLAMA_SERVER) $(MODELS_DIR)/$(qwen7b_model)

solar10b:
	@$(LLAMA_SERVER) $(MODELS_DIR)/$(solar10b_model)

starling7b:
	@$(LLAMA_SERVER) $(MODELS_DIR)/$(starling7b_model)

# Target to test the server
test:
	@node test.js

# Target to start the API
api:
	@bash -c "source venv/bin/activate && uvicorn api.main:app --reload --port 8001"

# Default target
all:
	@echo "Available models and their aliases:"
	@echo "gemma: $(gemma_model)"
	@echo "llama13b: $(llama13b_model)"
	@echo "meta8b: $(meta8b_model)"
	@echo "ministral8b: $(ministral8b_model)"
	@echo "qwen7b: $(qwen7b_model)"
	@echo "solar10b: $(solar10b_model)"
	@echo "starling7b: $(starling7b_model)"
	@echo "Use 'make <alias>' to launch the server with the specified model."
	@echo "Use 'make test' to test the server."
	@echo "Use 'make api' to start the API."

