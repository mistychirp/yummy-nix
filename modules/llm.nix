{ config, pkgs, lib, ... }:

# Local LLMs on the desktop (RX 5700 XT, gfx1010, 8 GB VRAM + 32 GB RAM).
# AMD dropped gfx1010 from ROCm, so everything here uses Vulkan (Mesa RADV)
# instead. See ~/Documents/llm/local-llm-summary.md.
{
  # Ollama as a system service. API on http://127.0.0.1:11434, models stored in
  # /var/lib/ollama. Usage: `ollama run <model>`, `ollama ps` shows the GPU/CPU split.
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    host = "127.0.0.1"; # local only; set "0.0.0.0" + openFirewall to expose on LAN
    environmentVariables = {
      OLLAMA_VULKAN = "1";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0"; # halves KV-cache VRAM, room for more context
      RADV_PERFTEST = "nogttspill";
    };
  };

  environment.systemPackages = with pkgs; [
    # llama.cpp (llama-server, llama-cli, ...) with the Vulkan backend: preferred
    # for Qwen3.5 and for MoE expert offload (--n-cpu-moe). Run it with
    # RADV_PERFTEST=nogttspill. Models from `-hf` go to ~/.cache/llama.cpp.
    llama-cpp-vulkan
    vulkan-tools # vulkaninfo: check that RADV sees the card
    amdgpu_top # VRAM / GPU load monitor
  ];
}
