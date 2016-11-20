# Relay Plugin

This plugin allows messages from OpenKore to be sent to an external server so they can be relayed to other services, such as a web interface or IRC channel.

The plugin runs in OpenKore and first sends messages to a node.js server running locally. The node server queues messages to be sent and resends messages in case of server downtime.
