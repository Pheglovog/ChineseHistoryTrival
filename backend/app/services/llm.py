"""LLM abstraction layer -- factory for DeepSeek, Claude, and Qwen models.

Usage::

    from services.llm import create_llm

    llm = create_llm()                       # uses default provider from settings
    llm = create_llm(model_name="deepseek-reasoner", temperature=0.3)
"""

from __future__ import annotations

from typing import Any

import structlog
from langchain_core.language_models import BaseChatModel

logger = structlog.get_logger()

# ---------------------------------------------------------------------------
# Lazy imports for optional provider packages.
# The heavy imports are placed inside the factory so that the module can be
# loaded even when one or more provider SDKs are not installed.
# ---------------------------------------------------------------------------

_PROVIDER_IMPORT_ERROR_MSG = (
    "Provider package for '{provider}' is not installed. "
    "Install it with:  pip install {pkg}"
)


def _get_settings() -> Any:
    """Import and return the application settings object.

    The import is deferred so that this module can be tested in isolation
    without pulling in the full FastAPI configuration machinery.
    """
    from app.config import settings  # noqa: WPS433  (lazy import by design)
    return settings


# ---------------------------------------------------------------------------
# Public factory
# ---------------------------------------------------------------------------

def create_llm(
    model_name: str | None = None,
    temperature: float = 0.7,
    *,
    max_tokens: int | None = None,
    streaming: bool = False,
) -> BaseChatModel:
    """Create a LangChain ``BaseChatModel`` based on the configured provider.

    The provider is read from ``settings.LLM_PROVIDER`` (default: ``"deepseek"``).

    Parameters
    ----------
    model_name:
        Override the default model for the chosen provider.  If ``None`` the
        provider-specific default is used.
    temperature:
        Sampling temperature.  ``0.0`` for deterministic output.
    max_tokens:
        Optional cap on the number of generated tokens.
    streaming:
        If ``True`` the model will yield chunks as they are generated.

    Returns
    -------
    BaseChatModel
        A ready-to-use chat model instance.

    Raises
    ------
    ValueError
        If the provider string is not recognised.
    """

    settings = _get_settings()
    provider: str = getattr(settings, "LLM_PROVIDER", "deepseek").lower()

    logger.info(
        "create_llm",
        provider=provider,
        model_name=model_name,
        temperature=temperature,
    )

    common_kwargs: dict[str, Any] = {
        "temperature": temperature,
        "streaming": streaming,
    }
    if max_tokens is not None:
        common_kwargs["max_tokens"] = max_tokens

    if provider == "deepseek":
        from langchain_openai import ChatOpenAI  # noqa: WPS433

        return ChatOpenAI(
            model=model_name or "deepseek-chat",
            api_key=settings.DEEPSEEK_API_KEY,
            base_url=settings.DEEPSEEK_BASE_URL,
            **common_kwargs,
        )

    if provider == "claude":
        from langchain_anthropic import ChatAnthropic  # noqa: WPS433

        return ChatAnthropic(
            model=model_name or "claude-sonnet-4-20250514",
            api_key=settings.CLAUDE_API_KEY,
            **common_kwargs,
        )

    if provider == "qwen":
        from langchain_openai import ChatOpenAI  # noqa: WPS433

        return ChatOpenAI(
            model=model_name or "qwen-plus",
            api_key=settings.QWEN_API_KEY,
            base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",
            **common_kwargs,
        )

    raise ValueError(f"Unknown LLM provider: {provider!r}")
