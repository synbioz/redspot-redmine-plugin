class Redspot::ViewHookListeners < Redmine::Hook::ViewListener
  render_on(:view_layouts_base_body_bottom, partial: 'redspot/header')
end