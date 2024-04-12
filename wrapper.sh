#!/bin/bash

# Extract Kafka broker list from arguments
kafkaBrokerList=""
for arg in "$@"; do
    case $arg in
        --kafkaBrokerList=*)
            kafkaBrokerList="${arg#*=}"
            ;;
        *)
            ;;
    esac
done

# If Kafka broker list is provided, redirect data to Azure Event Hubs
if [ -n "$kafkaBrokerList" ]; then
    # Azure Event Hubs configuration
    eventHubNamespace="kafkareplacement"
    eventHubSasKeyName="RootManageSharedAccessKey"
    eventHubSasKey="V0/vdNvrwFDmomIbU0nsnSE/5B6vA9TgM+AEhHfYbcE="
    eventHubConnection="Endpoint=sb://$eventHubNamespace.servicebus.windows.net/;SharedAccessKeyName=$eventHubSasKeyName;SharedAccessKey=$eventHubSasKey"

    # Function to send events to Event Hub
    send_to_eventhub() {
        local topic="$1"
        local message="$2"

        # Send message to Event Hub topic
        az eventhubs eventhub eventhub send --connection-string "$eventHubConnection" --hub-name "$topic" --message "$message"
    }

    # Loop to read from stdin and send to appropriate Event Hub topics
    while read -r line; do
        topic=$(echo "$line" | cut -d ' ' -f 1)
        message=$(echo "$line" | cut -d ' ' -f 2-)

        case $topic in
            auth_events)
                send_to_eventhub "$topic" "$message"
                ;;
            listen_events)
                send_to_eventhub "$topic" "$message"
                ;;
            page_view_events)
                send_to_eventhub "$topic" "$message"
                ;;
            status_change_events)
                send_to_eventhub "$topic" "$message"
                ;;
            *)
                echo "Unknown topic: $topic"
                ;;
        esac
    done

else
    # Run the original command with unchanged arguments
    exec "$@"
fi
