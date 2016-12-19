property :domain, String, name_property: true
property :email, String, required: true

property :binary_path, default: '/usr/local/sbin/lego'

property :accept_tos, [FalseClass, TrueClass], default: false

LETSENCRYPT_PROD_SERVER = 'https://acme-v01.api.letsencrypt.org/directory'
property :server_url, String,
         default: LETSENCRYPT_PROD_SERVER

property :output_path, String,
         default: ::File.join(Chef::Config[:file_cache_path], 'lego_certs')

property :challenge, %w(http tls dns), default: 'dns'
property :dns_provider, String, default: 'route53'

default_action :run

def cmd_with_args(r)
  cmd = "#{r.binary_path} "

  cmd += '-a ' if r.accept_tos
  cmd += "--domains #{r.domain} "
  cmd += "--email #{r.email} "
  cmd += "--server #{r.server_url} " if r.server_url != LETSENCRYPT_PROD_SERVER
  cmd += "--path #{r.output_path} "

  if r.challenge == "dns"
    cmd + "--dns=#{r.dns_provider} "
  else
    cmd + "--#{r.challenge} "
  end
end

action :run do
  directory output_path

  execute "#{cmd_with_args(new_resource)} run" do
    live_stream true
  end
end

action :renew do
  execute "#{cmd_with_args(new_resource)} renew" do
    live_stream true
  end
end
