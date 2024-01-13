# #!/bin/sh

# # Enabeling packet steering
# uci set network.globals.packet_steering=1

# # Enableing irq balancing to load up all the cores
# uci set irqbalance.irqbalance.enabled=1

# # Sleeping for 15 seconds to allow network and firewall to fully come up
# (sleep 15) &

# # Setting software offloading
# uci set firewall.@defaults[0].flow_offloading=1

# # Commiting changes
# uci commit

# # Restating firewall service
# /etc/init.d/firewall restart

# exit 0
