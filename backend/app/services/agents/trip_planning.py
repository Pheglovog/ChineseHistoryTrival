"""Trip Planning Agent -- scaffold with a LangGraph state graph.

This module provides the ``TripPlanningAgent`` class that orchestrates a
multi-step trip planning workflow using LangGraph.  The current implementation
establishes the state schema, graph topology and node stubs so that
downstream tasks can fill in the actual logic.

Task reference: 19.1 -- TripPlanningAgent with LangGraph state graph scaffold.
"""

from __future__ import annotations

from typing import Any, TypedDict

import structlog
from langchain_core.language_models import BaseChatModel
from langchain_core.tools import BaseTool
from langgraph.graph import END, StateGraph

from app.services.agents.base import BaseAgent

logger = structlog.get_logger()


# ---------------------------------------------------------------------------
# State definition
# ---------------------------------------------------------------------------

class TripState(TypedDict, total=False):
    """Mutable state flowing through the LangGraph workflow.

    Each key is populated by one or more graph nodes and consumed downstream.
    """

    # --- Inputs ---
    query: str                                  # User's natural-language request
    figure: str | None                          # Historical figure name
    era: str | None                             # Dynasty / period
    days: int | None                            # Desired trip length
    preferences: list[str]                      # User preferences (e.g. ["美食", "博物馆"])

    # --- Intermediate ---
    locations: list[dict[str, Any]]             # Geocoded locations with metadata
    validated_locations: list[dict[str, Any]]   # Locations after reachability check
    route_options: list[dict[str, Any]]         # Candidate route itineraries
    weather: dict[str, Any]                     # Weather data for target cities

    # --- Outputs ---
    selected_plan: dict[str, Any] | None        # The final chosen itinerary
    summary: str | None                         # Natural-language summary for the user

    # --- Bookkeeping ---
    errors: list[str]                           # Collected error messages


# ---------------------------------------------------------------------------
# Graph node functions
# ---------------------------------------------------------------------------

async def parse_intent_node(state: TripState) -> dict[str, Any]:
    """Extract structured travel intent from the user's free-text query.

    This node will invoke the LLM to parse out the figure, era, days and
    preferences from the raw query string.  For now it returns a placeholder.
    """
    logger.info("node_parse_intent", query=state.get("query"))
    # TODO (Task 19.2): Implement LLM-based intent parsing.
    return {
        "figure": state.get("figure"),
        "era": state.get("era"),
        "days": state.get("days"),
        "preferences": state.get("preferences", []),
    }


async def geocode_locations_node(state: TripState) -> dict[str, Any]:
    """Convert ancient place names to modern coordinates.

    Uses the ``name_matching_tool`` and ``geocode_tool`` from the tools
    module.  For now returns a placeholder list.
    """
    logger.info("node_geocode_locations", figure=state.get("figure"))
    # TODO (Task 19.3): Call name_matching_tool + geocode_tool.
    return {"locations": []}


async def validate_locations_node(state: TripState) -> dict[str, Any]:
    """Filter locations that are reachable and open to visitors."""
    logger.info("node_validate_locations", count=len(state.get("locations", [])))
    # TODO (Task 19.4): Check POI availability via amap_search_tool.
    return {"validated_locations": state.get("locations", [])}


async def generate_routes_node(state: TripState) -> dict[str, Any]:
    """Ask the LLM to propose multiple route options."""
    logger.info("node_generate_routes", days=state.get("days"))
    # TODO (Task 19.5): LLM-powered route generation.
    return {"route_options": []}


async def fetch_weather_node(state: TripState) -> dict[str, Any]:
    """Retrieve weather data for the cities on the route."""
    logger.info("node_fetch_weather")
    # TODO: Aggregate target cities and call weather_tool.
    return {"weather": {}}


async def select_plan_node(state: TripState) -> dict[str, Any]:
    """Select the best plan based on user preferences and weather."""
    logger.info("node_select_plan")
    # TODO: Ranking / selection logic.
    return {"selected_plan": None, "summary": None}


# ---------------------------------------------------------------------------
# Agent class
# ---------------------------------------------------------------------------

class TripPlanningAgent(BaseAgent):
    """Orchestrates a multi-step trip planning workflow using LangGraph.

    The graph topology is::

        parse_intent -> geocode_locations -> validate_locations
            -> generate_routes -> fetch_weather -> select_plan -> END

    Each node is an async function that receives and returns a ``TripState``
    dict.  Nodes communicate exclusively through the shared state.
    """

    def __init__(
        self,
        llm: BaseChatModel,
        tools: list[BaseTool] | None = None,
    ) -> None:
        super().__init__(llm=llm, tools=tools)
        self._graph = self._build_graph()

    # ------------------------------------------------------------------
    # BaseAgent contract
    # ------------------------------------------------------------------

    def get_prompt_template(self) -> str:
        """Return the system-level prompt for the trip planning workflow."""
        return (
            "你是华夏足迹的旅行规划助手。"
            "根据用户需求，规划一条围绕历史人物足迹的主题旅行路线。"
            "输出应当包含每日行程安排、交通建议和预算估算。"
        )

    async def run(self, input_data: dict[str, Any]) -> dict[str, Any]:
        """Execute the LangGraph workflow.

        Parameters
        ----------
        input_data:
            Must contain ``"query"``.  Optional: ``"figure"``, ``"era"``,
            ``"days"``, ``"preferences"``.

        Returns
        -------
        dict
            The final ``TripState`` after the graph completes.
        """
        self._log_start("trip_planning", query=input_data.get("query"))

        initial_state: TripState = {
            "query": input_data.get("query", ""),
            "figure": input_data.get("figure"),
            "era": input_data.get("era"),
            "days": input_data.get("days"),
            "preferences": input_data.get("preferences", []),
            "locations": [],
            "validated_locations": [],
            "route_options": [],
            "weather": {},
            "selected_plan": None,
            "summary": None,
            "errors": [],
        }

        compiled = self._graph.compile()
        result = await compiled.ainvoke(initial_state)

        self._log_end("trip_planning")
        return dict(result)

    # ------------------------------------------------------------------
    # Graph construction
    # ------------------------------------------------------------------

    @staticmethod
    def _build_graph() -> StateGraph:
        """Wire up the LangGraph state graph with all nodes and edges."""
        graph = StateGraph(TripState)

        # Register nodes
        graph.add_node("parse_intent", parse_intent_node)
        graph.add_node("geocode_locations", geocode_locations_node)
        graph.add_node("validate_locations", validate_locations_node)
        graph.add_node("generate_routes", generate_routes_node)
        graph.add_node("fetch_weather", fetch_weather_node)
        graph.add_node("select_plan", select_plan_node)

        # Define edges (linear pipeline for now)
        graph.set_entry_point("parse_intent")
        graph.add_edge("parse_intent", "geocode_locations")
        graph.add_edge("geocode_locations", "validate_locations")
        graph.add_edge("validate_locations", "generate_routes")
        graph.add_edge("generate_routes", "fetch_weather")
        graph.add_edge("fetch_weather", "select_plan")
        graph.add_edge("select_plan", END)

        return graph
