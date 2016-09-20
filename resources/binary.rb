property :version, name_property: true, identity: true
property :os, default: 'linux'
property :arch, default: 'amd64'

property :url, default: (lazy do
  [
    'https://github.com/xenolf/lego/releases/download',
    "v#{version}",
    "lego_#{os}_#{arch}.tar.xz"
  ].join('/')
end)
property :path, default: '/usr/local/sbin/lego', identity: true

property :owner, String, default: 'root'
property :group, String, default: 'root'
property :mode, default: '755'

action :install do
  include_recipe 'libarchive'

  archive_name = ::File.basename(url)

  archive_path = ::File.join(Chef::Config[:file_cache_path], archive_name)
  extracted_path = ::File.join(Chef::Config[:file_cache_path])

  remote_file archive_path do
    source url
  end

  libarchive_file archive_name do
    path archive_path
    extract_to extracted_path
  end

  remote_file path do
    source "file://#{extracted_path}/lego/lego"
    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
  end
end
