#!/bin/bash

KEYS_FILE="keys.txt"  # Файл со списком приватных ключей, по одному в строке

while true; do
    # Случайный номер от 1 до 10 для файла ordX.yaml
    ORD_NUM=$((RANDOM % 10 + 1))
    FILE="ord${ORD_NUM}.yaml"

    # Выбор случайного приватного ключа
    PRIVKEY=$(shuf -n 1 "$KEYS_FILE")

    # Случайная задержка от 120 до 420 секунд
    SLEEP_SECONDS=$((RANDOM % 301 + 120)) # 0–300 + 120 => 120–420

    echo "[$(date)] Запускаем для файла: $FILE с ключом: ${PRIVKEY:0:6}... (следующий запуск через $SLEEP_SECONDS секунд)"

    # Выполнение команды
    RUST_LOG=info boundless \
      --rpc-url "RPC" \
      --private-key "$PRIVKEY" \
      request submit "$FILE"

    # Ожидание перед следующим запуском
    sleep "$SLEEP_SECONDS"
done
