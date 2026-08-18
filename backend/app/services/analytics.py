from __future__ import annotations

import logging
from typing import Any, Protocol

logger = logging.getLogger("creatediff.analytics")


class AnalyticsSink(Protocol):
    async def track(self, event: str, *, user_id: str | None = None, properties: dict[str, Any] | None = None) -> None: ...


class LoggingAnalytics:
    async def track(self, event: str, *, user_id: str | None = None, properties: dict[str, Any] | None = None) -> None:
        logger.info("analytics event=%s user_id=%s properties=%s", event, user_id, properties or {})


analytics: AnalyticsSink = LoggingAnalytics()


async def track(event: str, *, user_id: str | None = None, properties: dict[str, Any] | None = None) -> None:
    await analytics.track(event, user_id=user_id, properties=properties)


class SentryReporter:
    """Optional adapter point; install/configure sentry-sdk without coupling the core."""
    def capture_exception(self, error: BaseException, **context: Any) -> None:
        logger.warning("sentry pending integration error_type=%s context_keys=%s", type(error).__name__, sorted(context.keys()))
