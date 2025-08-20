# syntax=docker/dockerfile:1
FROM python:3.13-slim-bookworm AS builder_base

ENV UV_LINK_MODE=copy \
  UV_COMPILE_BYTECODE=1 \
  UV_PYTHON_DOWNLOADS=never \
  UV_PROJECT_ENVIRONMENT=/app/.venv

COPY --from=ghcr.io/astral-sh/uv:0.7 /uv /uvx /bin/
COPY pyproject.toml uv.lock /_lock/
RUN --mount=type=cache,target=/root/.cache \
  cd /_lock && \
  uv sync --frozen --no-dev

##################################################################################

FROM python:3.13-slim-bookworm

# Create a non-root user.
RUN groupadd -r -g 1000 app \
  && useradd -r -u 1000 -d /app -g app -N app

COPY --from=builder_base --chown=app:app /app /app
ENV PATH=/app/.venv/bin:$PATH \
  PYTHONUNBUFFERED=1
USER app
CMD ["python", "--version"]
