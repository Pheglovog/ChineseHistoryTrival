"""Agent Hub -- central registry and request dispatcher for all agents."""

from __future__ import annotations

from enum import Enum
from typing import Any

import structlog

from app.services.agents.base import BaseAgent

logger = structlog.get_logger()


class AgentType(Enum):
    """Enumeration of every agent kind known to the application."""

    ROUTE_PLANNING = "route_planning"
    TRIP_PLANNING = "trip_planning"
    MATCHING = "matching"
    SUMMARY = "summary"
    IMAGE = "image"


class AgentHub:
    """Central registry that routes incoming requests to the correct agent.

    Usage::

        hub = AgentHub()
        hub.register(AgentType.ROUTE_PLANNING, route_agent)
        result = await hub.dispatch(AgentType.ROUTE_PLANNING, {...})
    """

    def __init__(self) -> None:
        self._agents: dict[AgentType, BaseAgent] = {}
        self.logger = structlog.get_logger().bind(component="agent_hub")

    # ------------------------------------------------------------------
    # Registration
    # ------------------------------------------------------------------

    def register(self, agent_type: AgentType, agent: BaseAgent) -> None:
        """Register *agent* under the given *agent_type* key.

        If the same key was previously registered the old entry is silently
        replaced and a warning is logged.
        """
        if agent_type in self._agents:
            self.logger.warning(
                "agent_replaced", agent_type=agent_type.value,
                old=type(self._agents[agent_type]).__name__,
                new=type(agent).__name__,
            )
        self._agents[agent_type] = agent
        self.logger.info("agent_registered", agent_type=agent_type.value, agent=type(agent).__name__)

    def unregister(self, agent_type: AgentType) -> None:
        """Remove the agent registered under *agent_type*, if any."""
        removed = self._agents.pop(agent_type, None)
        if removed is not None:
            self.logger.info("agent_unregistered", agent_type=agent_type.value)
        else:
            self.logger.warning("agent_unregister_missing", agent_type=agent_type.value)

    # ------------------------------------------------------------------
    # Dispatch
    # ------------------------------------------------------------------

    async def dispatch(self, agent_type: AgentType, input_data: dict[str, Any]) -> dict[str, Any]:
        """Route *input_data* to the agent identified by *agent_type*.

        Raises
        ------
        ValueError
            If no agent has been registered for the requested *agent_type*.
        """
        agent = self._agents.get(agent_type)
        if agent is None:
            self.logger.error("dispatch_unknown_agent", agent_type=agent_type.value)
            raise ValueError(f"Unknown agent type: {agent_type.value}")

        self.logger.info(
            "dispatch",
            agent_type=agent_type.value,
            agent=type(agent).__name__,
        )
        result = await agent.run(input_data)
        self.logger.info("dispatch_complete", agent_type=agent_type.value)
        return result

    # ------------------------------------------------------------------
    # Introspection
    # ------------------------------------------------------------------

    @property
    def registered_types(self) -> list[AgentType]:
        """Return a list of currently registered agent types."""
        return list(self._agents.keys())

    def is_registered(self, agent_type: AgentType) -> bool:
        """Return ``True`` if an agent exists for *agent_type*."""
        return agent_type in self._agents
