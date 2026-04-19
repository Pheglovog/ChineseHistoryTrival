"""Route Planning Agent -- recommends travel routes for historical figures.

This agent uses the LangChain ReAct (Reason + Act) pattern to:
  1.  Understand which historical figure and era the user is interested in.
  2.  Validate and geocode the relevant locations.
  3.  Produce multiple itinerary variants:
        - **经典路线** (Classic) -- must-see highlights.
        - **深度路线** (In-depth) -- off-the-beaten-path gems.
        - **精华路线** (Essence) -- time-efficient best-of.

Tasks implemented:
  - 15.1  LangChain ReAct agent with tool binding
  - 15.2  Prompt template with historical figure knowledge
  - 15.3  Multi-plan recommendation logic
  - 15.4  Location validation via tools
"""

from __future__ import annotations

import json
import re
from typing import Any

import structlog
from langchain.agents import AgentExecutor, create_react_agent
from langchain_core.language_models import BaseChatModel
from langchain_core.prompts import PromptTemplate
from langchain_core.tools import BaseTool

from app.services.agents.base import BaseAgent

logger = structlog.get_logger()

# ---------------------------------------------------------------------------
# System prompt (Task 15.2)
# ---------------------------------------------------------------------------

ROUTE_PLANNING_PROMPT = """\
你是一位资深的华夏文化旅游规划师，精通中国历史地理，擅长为用户设计"历史人物足迹"主题旅行路线。

## 你的能力

1. **历史知识**：你熟悉从先秦到明清各朝代的重要人物、事件及其活动地点。
2. **地理知识**：你能够将古地名（如长安、建康、汴梁）对应到现代城市。
3. **路线规划**：你能够根据用户的时间和偏好设计多条不同风格的路线。

## 工作流程

当用户提出需求后，请按以下步骤思考：

1. **理解需求**：确认用户感兴趣的历史人物、朝代、出行天数和偏好。
2. **查找地点**：使用工具将古地名转换为现代坐标，确认地点的可达性。
3. **生成路线**：为用户设计 **三种** 不同的行程方案：

### 路线类型
- **经典路线**：覆盖该人物一生中最著名的历史事件发生地，适合首次探访。
- **深度路线**：包含小众但与该人物密切相关的遗址、纪念馆，适合历史爱好者。
- **精华路线**：在有限天数内精选最值得探访的地点，适合时间紧张的旅行者。

## 输出格式

请以 JSON 格式输出，结构如下：

```json
{{
  "figure": "历史人物名",
  "era": "所属朝代",
  "plans": [
    {{
      "type": "经典路线",
      "summary": "一句话概述",
      "days": 5,
      "stops": [
        {{
          "day": 1,
          "ancient_name": "古地名",
          "modern_name": "现代地名",
          "location": "经度,纬度",
          "description": "该地点与历史人物的关联说明",
          "suggested_duration": "建议停留时间（小时）"
        }}
      ],
      "total_distance_km": 0,
      "tips": "旅行小贴士"
    }}
  ]
}}
```

## 注意事项
- 每条路线的每日行程安排应合理，避免跨城奔波。
- 考虑交通方式的实际可行性。
- 如果用户没有指定天数，默认推荐 3-5 天。
- 使用工具验证地点后，再生成最终路线。

## 可用工具

{{tools}}

## 当前对话

用户输入：{{input}}

{{agent_scratchpad}}
"""


# ---------------------------------------------------------------------------
# Agent implementation (Tasks 15.1, 15.3, 15.4)
# ---------------------------------------------------------------------------

class RoutePlanningAgent(BaseAgent):
    """Agent that plans historical figure themed travel routes.

    Uses the LangChain **ReAct** agent pattern so the LLM can iteratively
    call tools (geocoding, POI search, name matching) before producing the
    final itinerary.

    Multi-plan recommendation (Task 15.3):
        The prompt explicitly asks the LLM to produce three variants --
        经典, 深度, and 精华 -- so the user can choose the best fit.

    Location validation (Task 15.4):
        The ReAct loop lets the agent call ``geocode_tool`` and
        ``amap_search_tool`` to verify that each ancient place name has a
        valid modern counterpart before including it in the route.
    """

    def __init__(
        self,
        llm: BaseChatModel,
        tools: list[BaseTool] | None = None,
        *,
        max_iterations: int = 10,
        verbose: bool = False,
    ) -> None:
        super().__init__(llm=llm, tools=tools)
        self.max_iterations = max_iterations
        self.verbose = verbose
        self._executor: AgentExecutor | None = None

    # ------------------------------------------------------------------
    # BaseAgent contract
    # ------------------------------------------------------------------

    def get_prompt_template(self) -> str:
        """Return the ReAct system prompt (Task 15.2)."""
        return ROUTE_PLANNING_PROMPT

    async def run(self, input_data: dict[str, Any]) -> dict[str, Any]:
        """Plan routes for a historical figure.

        Parameters
        ----------
        input_data:
            Must contain ``"query"`` (the user's natural-language request).
            Optional keys: ``"figure"``, ``"era"``, ``"days"``,
            ``"preferences"``.

        Returns
        -------
        dict
            The parsed JSON route plan.  If the agent fails to produce valid
            JSON, ``{"error": ..., "raw": ...}`` is returned.
        """
        self._log_start("route_planning", query=input_data.get("query"))

        executor = self._get_or_create_executor()
        query = input_data.get("query", "")

        try:
            raw_output: dict[str, Any] = await executor.ainvoke({"input": query})
        except Exception as exc:
            self.logger.exception("route_planning_failed", error=str(exc))
            return {"error": f"Agent execution failed: {exc}"}

        result = self._parse_result(raw_output)
        self._log_end("route_planning")
        return result

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------

    def _get_or_create_executor(self) -> AgentExecutor:
        """Lazy-build the ``AgentExecutor`` on first use (Task 15.1)."""
        if self._executor is not None:
            return self._executor

        react_prompt = PromptTemplate.from_template(ROUTE_PLANNING_PROMPT)

        agent = create_react_agent(
            llm=self.llm,
            tools=self.tools,
            prompt=react_prompt,
        )

        self._executor = AgentExecutor(
            agent=agent,
            tools=self.tools,
            max_iterations=self.max_iterations,
            verbose=self.verbose,
            handle_parsing_errors=True,
        )
        return self._executor

    @staticmethod
    def _parse_result(raw_output: dict[str, Any]) -> dict[str, Any]:
        """Try to extract and parse the JSON plan from agent output."""
        output_str = raw_output.get("output", "")

        # Attempt direct JSON parse
        try:
            parsed = json.loads(output_str)
            if isinstance(parsed, dict):
                return parsed
        except json.JSONDecodeError:
            pass

        # Attempt to extract JSON block from markdown code fences
        json_match = re.search(r"```(?:json)?\s*\n?(.*?)```", output_str, re.DOTALL)
        if json_match:
            try:
                parsed = json.loads(json_match.group(1).strip())
                if isinstance(parsed, dict):
                    return parsed
            except json.JSONDecodeError:
                pass

        # Return raw text if we cannot parse JSON
        return {"raw": output_str}
