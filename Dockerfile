FROM mcr.microsoft.com/playwright/python:v1.40.0-jammy

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    default-jre \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && node --version \
    && npm --version

# Install Allure CLI
RUN cd /tmp \
    && wget --no-check-certificate -O allure-2.24.0.tgz https://github.com/allure-framework/allure2/releases/download/2.24.0/allure-2.24.0.tgz \
    || curl -L -o allure-2.24.0.tgz https://github.com/allure-framework/allure2/releases/download/2.24.0/allure-2.24.0.tgz \
    && tar -xzf allure-2.24.0.tgz \
    && mv allure-2.24.0 /opt/ \
    && ln -sf /opt/allure-2.24.0/bin/allure /usr/bin/allure \
    && rm allure-2.24.0.tgz \
    && cd /

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add paths
ENV PATH="/root/.local/bin:/opt/allure-2.24.0/bin:${PATH}"

# Verify all installations
RUN python --version \
    && node --version \
    && npm --version \
    && allure --version \
    && uv --version

WORKDIR /app
