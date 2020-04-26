#!/bin/bash
WEBHOOK_URL='https://hooks.slack.com/services/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'
curl -X POST -s -o /dev/null -H 'Content-type: application/json' --data "{\"text\": \"$1\"}" $WEBHOOK_URL
