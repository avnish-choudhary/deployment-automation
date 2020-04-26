#!/bin/bash
WEBHOOK_URL='https://hooks.slack.com/services/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'
curl -X POST -s -o /dev/null -H 'Content-type: application/json' --data "{\"text\": \"$1\"}" $WEBHOOK_URL
