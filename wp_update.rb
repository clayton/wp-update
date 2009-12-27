#!/usr/bin/ruby

# This script can be used to update a virtual host's copy of Wordpress
#
# ASSUMPTIONS:
# * Virtual hosts are located in /etc/nginx/vhosts
# * Non-customized WP files include wp-config.php and the wp-content directory
# * The latest copy of non-customized WP files are located in /etc/nginx/wp-versions/latest
# * The vhost name that is passed in via the command line is in the form of example.tld (no sub-domain support)
require 'rubygems'
require 'fileutils'

class WordpressSite

  attr_accessor :vhost_name, :document_root, :vhost_root, :shared_path, :copied_latest_path

  @@latest_wp = File.join("/","etc", "nginx", "wp-versions", "latest")

  def initialize
    self.document_root = File.join("/etc", "nginx", "vhosts", ARGV[0], "httpdocs")
    self.vhost_root    = File.join("/etc", "nginx", "vhosts", ARGV[0])
    self.vhost_name    = ARGV[0].split(".").last
    self.shared_path   = File.join("/etc", "nginx", "vhosts", ARGV[0], "shared")
  end

  def update
    puts "Updating #{ARGV[0]}\n\n"
    copy_latest_wp
    symlink_document_root
    symlink_custom
    puts "\nCompleted updating #{ARGV[0]}"
  end

  def copy_latest_wp
    copied_latest = File.join(vhost_root, "current")
    puts "\t** copying #{@@latest_wp} to #{File.join(vhost_root, "current")}\n"
    FileUtils.cp_r(@@latest_wp, copied_latest)
    self.copied_latest_path = copied_latest
  end

  def symlink_document_root
    puts "\t** executing -- cd #{vhost_root} && ln -ns #{copied_latest_path} #{document_root}\n"
    `cd #{vhost_root} && ln -ns #{copied_latest_path} #{document_root}`
  end

  def symlink_custom
    puts "\t** executing -- cd #{vhost_root} && ln -ns #{shared_wp_config_path} #{linked_wp_config_path}\n"
    `cd #{vhost_root} && ln -ns #{shared_wp_config_path} #{linked_wp_config_path}`
    puts "\t** executing -- cd #{vhost_root} && ln -ns #{shared_wp_content_path} #{linked_wp_content_path}\n"
    `cd #{vhost_root} && ln -ns #{shared_wp_content_path} #{linked_wp_content_path}`
  end

private

  def shared_wp_config_path
    File.join(shared_path, "wp-config.php")
  end

  def linked_wp_config_path
    File.join(document_root, "wp-config.php")
  end

  def shared_wp_content_path
    File.join(shared_path, "wp-content")
  end
  def linked_wp_content_path
    File.join(document_root, "wp-content")
  end
end

virtual_host = WordpressSite.new
virtual_host.update
