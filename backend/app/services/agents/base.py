"""Base class for all LangChain agents in the华夏足迹 application."""

from abc import ABC, abstractmethod
from typing import Any

import structlog
from langchain_core.language_models import BaseChatModel
from langchain_core.tools import BaseTool

logger = structlog.get_logger()


class BaseAgent(ABC):
    """Abstract base class for all LangChain agents.

    Every concrete agent must implement:
      - ``run``: async entry point invoked by the AgentHub dispatcher.
      - ``get_prompt_template``: return the system-level prompt used by the agent.

    Parameters
    ----------
    llm:
        A LangChain-compatible chat model (e.g. ``ChatOpenAI``, ``ChatAnthropic``).
    tools:
        An optional list of LangChain ``BaseTool`` instances the agent can call.
    """

    def __init__(self, llm: BaseChatModel, tools: list[BaseTool] | None = None) -> None:
        self.llm = llm
        self.tools: list[BaseTool] = tools or []
        self.logger = structlog.get_logger().bind(agent=self.__class__.__name__)

    # ------------------------------------------------------------------
    # Abstract contract
    # ------------------------------------------------------------------

    @abstractmethod
    async def run(self, input_data: dict[str, Any]) -> dict[str, Any]:
        """Execute the agent with the given *input_data* and return a result dict."""
        ...

    @abstractmethod
    def get_prompt_template(self) -> str:
        """Return the system prompt template string used by this agent."""
        ...

    # ------------------------------------------------------------------
    # Helpers available to all agents
    # ------------------------------------------------------------------

    def _log_start(self, action: str, **kwargs: Any) -> None:
        """Emit a structured log at the beginning of an action."""
        self.logger.info("agent_start", action=action, **kwargs)

    def _log_end(self, action: str, **kwargs: Any) -> None:
        """Emit a structured log at the end of an action."""
        self.logger.info("agent_end", action=action, **kwargs)
