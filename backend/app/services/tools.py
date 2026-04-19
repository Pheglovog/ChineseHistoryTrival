"""Common LangChain tools shared across agents.

Tools implemented here:
    - ``amap_search_tool``   -- Search POI (points of interest) via the AMap API.
    - ``geocode_tool``       -- Convert a textual address to latitude/longitude.
    - ``weather_tool``       -- Fetch current / forecast weather for a location.
    - ``name_matching_tool`` -- Match ancient Chinese place names to modern ones.

Each tool is a ``@tool``-decorated async function so it integrates natively
with LangChain agents and the ``Tool`` executor.
"""

from __future__ import annotations

import json
from typing import Any

import httpx
import structlog
from langchain_core.tools import tool

logger = structlog.get_logger()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_AMAP_BASE = "https://restapi.amap.com/v3"
_SETTINGS_CACHE: Any | None = None


def _get_settings() -> Any:
    """Lazy-load application settings (avoids circular imports at module level)."""
    global _SETTINGS_CACHE  # noqa: PLW0603
    if _SETTINGS_CACHE is None:
        from app.config import settings  # noqa: WPS433
        _SETTINGS_CACHE = settings
    return _SETTINGS_CACHE


async def _amap_get(endpoint: str, params: dict[str, Any]) -> dict[str, Any]:
    """Perform an asynchronous GET against the AMap REST API.

    Automatically injects the ``key`` query parameter from application settings.
    """
    settings = _get_settings()
    params["key"] = settings.AMAP_API_KEY
    params["output"] = "JSON"

    url = f"{_AMAP_BASE}/{endpoint}"
    logger.debug("amap_request", url=url, params={k: v for k, v in params.items() if k != "key"})

    async with httpx.AsyncClient(timeout=10.0) as client:
        response = await client.get(url, params=params)
        response.raise_for_status()
        data: dict[str, Any] = response.json()

    if data.get("status") != "1":
        logger.error("amap_error", info=data.get("info"), infocode=data.get("infocode"))
        raise RuntimeError(f"AMap API error: {data.get('info', 'unknown')}")

    return data


# ---------------------------------------------------------------------------
# Tool 1: AMap POI Search
# ---------------------------------------------------------------------------

@tool
async def amap_search_tool(query: str, city: str | None = None, citylimit: bool = False) -> str:
    """Search for points of interest (POI) via the AMap (Gaode) API.

    Args:
        query: Search keyword, e.g. "故宫" or "酒店".
        city: Optional city name or adcode to scope the search.
        citylimit: If True, restrict results to the specified city.

    Returns:
        A JSON string containing a list of POI results.  Each entry includes
        ``name``, ``location`` (lng,lat), ``address``, ``tel`` and ``type``.
    """
    logger.info("tool_amap_search", query=query, city=city)

    params: dict[str, Any] = {
        "keywords": query,
        "offset": 10,
        "page": 1,
        "citylimit": str(citylimit).lower(),
    }
    if city:
        params["city"] = city

    data = await _amap_get("place/text", params)
    pois = data.get("pois", [])

    results: list[dict[str, Any]] = []
    for poi in pois:
        results.append({
            "name": poi.get("name"),
            "location": poi.get("location"),       # "lng,lat"
            "address": poi.get("address"),
            "tel": poi.get("tel"),
            "type": poi.get("type"),
            "adcode": poi.get("adcode"),
        })

    return json.dumps(results, ensure_ascii=False)


# ---------------------------------------------------------------------------
# Tool 2: Geocode
# ---------------------------------------------------------------------------

@tool
async def geocode_tool(address: str, city: str | None = None) -> str:
    """Convert a textual address into geographic coordinates (longitude, latitude).

    Args:
        address: The address or place name to geocode.
        city: Optional city to narrow the search scope.

    Returns:
        A JSON string with ``location`` (lng,lat), ``formatted_address``,
        ``province``, ``city``, ``district`` and ``adcode``.
    """
    logger.info("tool_geocode", address=address, city=city)

    params: dict[str, Any] = {"address": address}
    if city:
        params["city"] = city

    data = await _amap_get("geocode/geo", params)
    geocodes = data.get("geocodes", [])

    if not geocodes:
        return json.dumps({"error": "No results found"}, ensure_ascii=False)

    geo = geocodes[0]
    result: dict[str, Any] = {
        "location": geo.get("location"),
        "formatted_address": geo.get("formatted_address"),
        "province": geo.get("province"),
        "city": geo.get("city"),
        "district": geo.get("district"),
        "adcode": geo.get("adcode"),
        "level": geo.get("level"),
    }

    return json.dumps(result, ensure_ascii=False)


# ---------------------------------------------------------------------------
# Tool 3: Weather
# ---------------------------------------------------------------------------

@tool
async def weather_tool(city: str, extensions: str = "base") -> str:
    """Fetch weather information for a Chinese city via the AMap weather API.

    Args:
        city: City name or adcode.
        extensions: ``"base"`` for current weather (default) or ``"all"`` for
            a forecast.

    Returns:
        A JSON string with weather data including temperature, weather
        description, wind direction and power.
    """
    logger.info("tool_weather", city=city, extensions=extensions)

    params: dict[str, Any] = {
        "city": city,
        "extensions": extensions,
    }
    data = await _amap_get("weather/weatherInfo", params)
    lives = data.get("lives", []) or data.get("forecasts", [])

    return json.dumps(lives, ensure_ascii=False)


# ---------------------------------------------------------------------------
# Tool 4: Ancient-to-modern name matching
# ---------------------------------------------------------------------------

# A small built-in lookup table.  In production this would be backed by a
# database or a dedicated vector index.

_NAME_DB: dict[str, dict[str, str]] = {
    "长安": {"modern": "西安", "province": "陕西", "note": "西汉、隋、唐等多个朝代的首都"},
    "洛阳": {"modern": "洛阳", "province": "河南", "note": "东汉、魏、晋等朝代的首都"},
    "建康": {"modern": "南京", "province": "江苏", "note": "东晋及南朝首都"},
    "汴梁": {"modern": "开封", "province": "河南", "note": "北宋首都"},
    "临安": {"modern": "杭州", "province": "浙江", "note": "南宋首都"},
    "金陵": {"modern": "南京", "province": "江苏", "note": "南京古称"},
    "燕京": {"modern": "北京", "province": "北京", "note": "北京古称，辽/金陪都"},
    "大都": {"modern": "北京", "province": "北京", "note": "元朝首都"},
    "咸阳": {"modern": "咸阳", "province": "陕西", "note": "秦朝首都"},
    "彭城": {"modern": "徐州", "province": "江苏", "note": "徐州古称"},
    "会稽": {"modern": "绍兴", "province": "浙江", "note": "绍兴古称"},
    "姑苏": {"modern": "苏州", "province": "江苏", "note": "苏州古称"},
    "余杭": {"modern": "杭州", "province": "浙江", "note": "杭州古称"},
    "襄阳": {"modern": "襄阳", "province": "湖北", "note": "三国军事重镇"},
    "荆州": {"modern": "荆州", "province": "湖北", "note": "三国时期战略要地"},
    "成都": {"modern": "成都", "province": "四川", "note": "蜀汉首都"},
    "许昌": {"modern": "许昌", "province": "河南", "note": "东汉末年曹操的都城"},
    "邺城": {"modern": "临漳", "province": "河北", "note": "曹魏、后赵等政权都城"},
    "敦煌": {"modern": "敦煌", "province": "甘肃", "note": "丝绸之路重镇"},
    "凉州": {"modern": "武威", "province": "甘肃", "note": "河西走廊重镇"},
    "益州": {"modern": "成都", "province": "四川", "note": "汉代十三州之一"},
    "幽州": {"modern": "北京", "province": "北京", "note": "汉代十三州之一"},
    "并州": {"modern": "太原", "province": "山西", "note": "汉代十三州之一"},
    "交州": {"modern": "广州", "province": "广东", "note": "汉代十三州之一"},
}


@tool
async def name_matching_tool(ancient_name: str) -> str:
    """Match an ancient Chinese place name to its modern equivalent.

    The tool consults an internal knowledge base that maps historical names
    (e.g. "长安") to present-day cities and provinces.

    Args:
        ancient_name: An ancient Chinese place name.

    Returns:
        A JSON string with ``ancient_name``, ``modern_name``, ``province``
        and ``note``.  If no match is found ``modern_name`` will be ``null``.
    """
    logger.info("tool_name_matching", ancient_name=ancient_name)

    match = _NAME_DB.get(ancient_name)
    if match:
        result: dict[str, Any] = {
            "ancient_name": ancient_name,
            "modern_name": match["modern"],
            "province": match["province"],
            "note": match["note"],
        }
    else:
        # Fuzzy hint: return null so the agent knows to ask the user or try
        # an alternative lookup strategy.
        result = {
            "ancient_name": ancient_name,
            "modern_name": None,
            "province": None,
            "note": "No match found in the built-in database.",
        }

    return json.dumps(result, ensure_ascii=False)
