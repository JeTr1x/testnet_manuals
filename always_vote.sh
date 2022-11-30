#!/bin/bash

set -e

current_proposal=$(/root/.kyve/cosmovisor/current/bin/chaind q gov proposals --node https://rpc.korellia.kyve.network:443 --limit 10000 -o json | jq -r '.proposals[] | select(.status == "PROPOSAL_STATUS_VOTING_PERIOD") | .id' | tail -n 1)
current_proposal=170

echo "Last proposal is: $current_proposal"

while true
do
  last_proposal=$(/root/.kyve/cosmovisor/current/bin/chaind query gov proposals --status voting_period --reverse --limit 1 --node https://rpc.korellia.kyve.network:443 -o json | jq -r '.proposals[] | select(.status == "PROPOSAL_STATUS_VOTING_PERIOD") | .id' | tail -n 1)

  if [[ $current_proposal -lt $last_proposal ]]
  then
    echo "New proposal: $last_proposal"
    echo "Voting..."
    /root/.kyve/cosmovisor/current/bin/chaind tx gov vote $last_proposal yes --from wallet --chain-id korellia --node https://rpc.korellia.kyve.network:443 -y --fees 200000tkyve
    current_proposal=$last_proposal
  fi

  sleep 1
done
