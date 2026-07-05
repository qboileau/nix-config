{
  lib,
  python313Packages,
  fetchFromGitHub,
}:
# Usage : 
# fcc-server (start the server on localhost8082)
# fcc-claude or free-claude-code (Start claude code CLI with ANTHROPIC_BASE_URL=http://localhost:8082)
# Note: python313 is used because pydantic-core's pyo3 dependency does not yet support Python 3.14
python313Packages.buildPythonApplication {
  pname = "free-claude-code";
  version = "unstable-2025-05-23";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Alishahryar1";
    repo = "free-claude-code";
    rev = "428746e0e0f2045e4a9a1fc93e1c1907bbe0419d";
    hash = "sha256-1h2d02b9brhbMsbI8cpFeRNiD7QPgGHRcTB/I8l4+PE=";
  };

  build-system = with python313Packages; [ hatchling ];

  dependencies = with python313Packages; [
    fastapi
    uvicorn
    httpx
    markdown-it-py
    pydantic
    python-dotenv
    tiktoken
    python-telegram-bot
    discordpy
    pydantic-settings
    openai
    loguru
    aiohttp
  ];

  # Fix: @model_validator methods use `-> Settings` as return annotation.
  # In Python 3.13 pydantic resolves this eagerly during class construction,
  # before Settings is fully assigned, causing NameError.
  # Upstream targets Python 3.14 where deferred annotations (PEP 749) make this work.
  postPatch = ''
    sed -i 's/) -> Settings:/) -> "Settings":/g' config/settings.py
  '';

  doCheck = false;
  pythonRelaxDeps = true;

  meta = {
    description = "Drop-in proxy for Claude Code routing Anthropic API calls to free and local providers";
    homepage = "https://github.com/Alishahryar1/free-claude-code";
    license = lib.licenses.mit;
    mainProgram = "fcc-server";
  };
}
