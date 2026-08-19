mohamed/ubuntu
postgres/pgadmin1

sudo systemctl status postgresql



# Check if it's enabled to start on boot
sudo systemctl is-enabled postgresql

# Just check if it's active (returns "active" or "inactive")
sudo systemctl is-active postgresql

# Check status of a specific version (if multiple are installed)
sudo systemctl status postgresql@14-main

# See all postgresql-related units (useful since Ubuntu often runs versioned instances)
sudo systemctl list-units --all | grep postgresql