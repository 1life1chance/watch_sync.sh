# watch_sync.sh
Вот простой Bash-скрипт, который будет отслеживать прогресс синхронизации geth через RPC и показывать текущий/максимальный блок, пока не догоним сеть
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

==================================================
✅ Как использовать:
Сохраните скрипт:

bash
Копировать
Редактировать
nano watch_sync.sh
Вставьте содержимое, сохраните (Ctrl+O, Enter, Ctrl+X).

Сделайте исполняемым:

bash
Копировать
Редактировать
chmod +x watch_sync.sh
Установите jq и bc, если не установлены:

bash
Копировать
Редактировать
apt update && apt install -y jq bc
Запустите скрипт:

bash
Копировать
Редактировать
./watch_sync.sh
Он будет обновлять статус каждые 10 секунд, пока синхронизация не завершится.
