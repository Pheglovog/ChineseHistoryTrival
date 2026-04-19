"""Summary Agent -- classical Chinese travel writing generation.

Generates a literary travel summary (游记) in the style of classical Chinese
prose (e.g. 《岳阳楼记》, 《醉翁亭记》), drawing on the itinerary produced
by the route-planning agent.

Task reference: 20.4 -- SummaryAgent for classical travel writing generation.
"""

from __future__ import annotations

import json
import re
from typing import Any

import structlog
from langchain_core.language_models import BaseChatModel
from langchain_core.messages import HumanMessage, SystemMessage
from langchain_core.tools import BaseTool

from app.services.agents.base import BaseAgent

logger = structlog.get_logger()

# ---------------------------------------------------------------------------
# Prompt (Task 20.4)
# ---------------------------------------------------------------------------

SUMMARY_SYSTEM_PROMPT = """\
你是一位精通古文的文学大师，擅长以文言文风格撰写游记。你的文字应当:

1. **文风古雅**：仿照《岳阳楼记》《醉翁亭记》《徐霞客游记》的行文风格。
2. **史实准确**：涉及的历史事件、人物生平应准确无误。
3. **地理真实**：描写的山川地貌应与实际地理相符。
4. **情景交融**：将历史人物的命运与自然景观融为一体。
5. **首尾呼应**：文章应有完整的结构，从出发到归途，有始有终。

## 输出要求

请生成一篇完整的文言文游记，包含以下部分：

1. **题记**：简述旅行的缘起和目的（50-100字）。
2. **正文**：按照行程顺序描写各地的所见所感，结合历史典故（500-1000字）。
3. **结语**：以议论或抒情收束全文（100-200字）。
4. **白话译文**：附上现代汉语译文，便于当代读者理解。
5. **旅行建议**：3-5条实用旅行小贴士。

请以 JSON 格式输出：

```json
{{
  "title": "游记标题",
  "preface": "题记内容",
  "body": "正文内容（可包含多个段落，用 \\n 分隔）",
  "conclusion": "结语内容",
  "translation": "白话译文",
  "tips": ["建议1", "建议2"]
}}
```
"""


# ---------------------------------------------------------------------------
# Agent
# ---------------------------------------------------------------------------

class SummaryAgent(BaseAgent):
    """Generates a classical Chinese travel essay based on an itinerary.

    This is a straightforward LLM-call agent -- no tool usage or multi-step
    graph is required.  The prompt combines the system template with the
    itinerary data and the LLM produces the essay.

    Parameters
    ----------
    llm:
        A LangChain-compatible chat model.
    tools:
        Optional tools (unused by this agent but accepted for interface
        consistency).
    """

    def __init__(
        self,
        llm: BaseChatModel,
        tools: list[BaseTool] | None = None,
    ) -> None:
        super().__init__(llm=llm, tools=tools)

    # ------------------------------------------------------------------
    # BaseAgent contract
    # ------------------------------------------------------------------

    def get_prompt_template(self) -> str:
        """Return the system prompt for classical travel writing."""
        return SUMMARY_SYSTEM_PROMPT

    async def run(self, input_data: dict[str, Any]) -> dict[str, Any]:
        """Generate a classical travel summary.

        Parameters
        ----------
        input_data:
            Should contain ``"itinerary"`` (a dict or JSON string produced
            by the route-planning agent).  Optional: ``"style"`` to
            influence the literary style (e.g. "豪放", "婉约").

        Returns
        -------
        dict
            The generated essay.  On success the dict contains ``"title"``,
            ``"preface"``, ``"body"``, ``"conclusion"``, ``"translation"``
            and ``"tips"``.  On failure ``{"error": ...}`` is returned.
        """
        self._log_start("summary", itinerary_present="itinerary" in input_data)

        itinerary = input_data.get("itinerary", {})
        style = input_data.get("style", "豪放")

        # Build the user message from itinerary data
        itinerary_text = self._serialize_itinerary(itinerary)
        user_content = (
            f"请根据以下旅行路线，撰写一篇{style}风格的文言文游记：\n\n"
            f"{itinerary_text}"
        )

        messages = [
            SystemMessage(content=SUMMARY_SYSTEM_PROMPT),
            HumanMessage(content=user_content),
        ]

        try:
            response = await self.llm.ainvoke(messages)
            result = self._parse_response(response.content)
        except Exception as exc:
            self.logger.exception("summary_failed", error=str(exc))
            return {"error": f"Summary generation failed: {exc}"}

        self._log_end("summary")
        return result

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _serialize_itinerary(itinerary: Any) -> str:
        """Turn the itinerary into a human-readable block for the LLM."""
        if isinstance(itinerary, str):
            return itinerary

        if isinstance(itinerary, dict):
            try:
                return json.dumps(itinerary, ensure_ascii=False, indent=2)
            except (TypeError, ValueError):
                return str(itinerary)

        return str(itinerary)

    @staticmethod
    def _parse_response(content: str) -> dict[str, Any]:
        """Extract the JSON essay from the LLM response."""
        # Direct parse
        try:
            parsed = json.loads(content)
            if isinstance(parsed, dict):
                return parsed
        except json.JSONDecodeError:
            pass

        # Extract from markdown code fences
        json_match = re.search(r"```(?:json)?\s*\n?(.*?)```", content, re.DOTALL)
        if json_match:
            try:
                parsed = json.loads(json_match.group(1).strip())
                if isinstance(parsed, dict):
                    return parsed
            except json.JSONDecodeError:
                pass

        # Fallback: wrap raw text
        return {
            "title": "游记",
            "preface": "",
            "body": content,
            "conclusion": "",
            "translation": "",
            "tips": [],
        }
