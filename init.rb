Redmine::Plugin.register :redspot do
  name 'Redspot plugin'
  author 'Victor Darras'
  description 'This is a plugin for Redmine'
  version File.read(File.expand_path("../VERSION", __FILE__))
  url '/redspot'
  author_url 'http://synbioz.com'
  require_dependency 'redspot/view_hook_listeners'
end