FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

RUN groupadd --system app && useradd --system --gid app --home-dir /app app

COPY requirements.txt ./
RUN python -m pip install --no-cache-dir -r requirements.txt

COPY app.py provider_checkout.py stripe_checkout.py billing_address_resolver.py sentinel_token.py gen_token_jsdom.js sentinel_sdk_full.js ./
COPY static ./static
COPY docs ./docs

RUN mkdir -p /app/runtime \
    && chown -R app:app /app

USER app

VOLUME ["/app/runtime"]

EXPOSE 9763

ENV PAY153_HOST=0.0.0.0 PAY153_PORT=9763

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:9763/', timeout=3)" || exit 1

CMD ["python", "app.py"]
