FROM jakobhoeg/nextjs-ollama-ui:latest AS web-ui
FROM ollama/ollama:latest

ARG MODELS=deepseek-r1:1.5b
RUN ollama serve & sleep 3 && for model in $MODELS; do ollama pull $model ; done;
# DeepSeek-R1-Distill-Qwen-1.5B

RUN apt-get update && apt-get install -y bash curl

WORKDIR /ollama-ui
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get update && apt-get install -y nodejs
# Copy built files from the builder stage
COPY --from=web-ui /app/.next /ollama-ui/.next
COPY --from=web-ui /app/public /ollama-ui/public
COPY --from=web-ui /app/package.json /ollama-ui/package.json
COPY --from=web-ui /app/package-lock.json /ollama-ui/package-lock.json
COPY --from=web-ui /app/node_modules /ollama-ui/node_modules

COPY start.sh /bin/start.sh
RUN chmod +x /bin/start.sh

ENV OLLAMA_URL=http://localhost:11434

EXPOSE 11434 3000

ENTRYPOINT ["/bin/start.sh"]
