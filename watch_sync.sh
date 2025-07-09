#!/bin/bash

RPC_URL="http://localhost:8545"

echo "⏳ Отслеживание синхронизации geth..."

while true; do
  RESPONSE=$(curl -s -X POST "$RPC_URL" \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}')
  
  SYNCING=$(echo "$RESPONSE" | jq -r '.result | type')

  if [ "$SYNCING" == "boolean" ]; then
    echo "✅ Синхронизация завершена!"
    BLOCK=$(curl -s -X POST "$RPC_URL" \
      -H "Content-Type: application/json" \
      -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r '.result')
    printf "🔗 Текущий блок: %d\n" "$((16#${BLOCK:2}))"
    break
  else
    CURRENT=$(echo "$RESPONSE" | jq -r '.result.currentBlock')
    HIGHEST=$(echo "$RESPONSE" | jq -r '.result.highestBlock')
    printf "📦 %s / %s (%.2f%%)\n" \
      "$((16#${CURRENT:2}))" \
      "$((16#${HIGHEST:2}))" \
      "$(echo "scale=2; 100 * $((16#${CURRENT:2})) / $((16#${HIGHEST:2}))" | bc)"
  fi

  sleep 10
done
