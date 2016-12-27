#!/bin/bash

# Build a list of location stanzas from the environment
locations=()
for ep in ${ENDPOINTS}; do
    pieces=( $(echo ${ep} | tr '|' ' ') )
    [[ ${#pieces[@]} -lt 2 ]] && continue
    locations+=("location ${pieces[0]} { proxy_pass ${pieces[1]}; }")
done

# Write the nginx config file
IFS=$'\n'
echo "nginx-configure: Writing new locations to nginx config:"
echo "${locations[@]}"
perl -pe 's#__LOCATIONS__#'"${locations[*]}"'#' template-nginx-proxy.conf > /etc/nginx/conf.d/proxy.conf

# Start nginx
echo "nginx-configure: Starting nginx"
supervisorctl start nginx

