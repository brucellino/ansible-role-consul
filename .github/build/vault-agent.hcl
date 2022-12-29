pid_file = "./pidfile"

auto_auth {
  method {
    type = "approle"
    mount_path = "auth/hashiatho.me"
    config = {
      role_id_file_path = "vault_roleid"
      remove_secret_id_file_after_reading = false
      secret_id_response_wrapping_path = "vault_secretid"
      role = "consul-secrets"
    }
  }

  sink "file" {
    wrap_ttl = "10m"
    config = {
      path = ".token"
    }
  }
}
