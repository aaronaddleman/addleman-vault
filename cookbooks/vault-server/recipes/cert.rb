
if !(File.exist? node['selfsigned_certificate']['destination'])
  log "No self-signed certificate found (targeted destination: #{node['selfsigned_certificate']['destination']}"
  include_recipe "selfsigned_certificate::default"
  log "created th server self-signed certificate to #{node['selfsigned_certificate']['destination']}"
else
  log "Certificate already exists in #{node['selfsigned_certificate']['destination']}, no overriding."
end
