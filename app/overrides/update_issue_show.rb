Deface::Override.new :virtual_path  => "issues/show",
                     :name          => "add_check_doc_button_to_issue_show_page",
                     :insert_before => "div#issue_tree",
                     :text          => <<-EOS

  <% if Setting.plugin_redmine_keywords['custom_field_visible'] == '1' %>
    <% if Setting.plugin_redmine_keywords['custom_field_tracker_ids'].include?(@issue.try(:tracker_id).to_s)%>
      <%= button_to 'Check docs',
          check_files_path(id: @issue.id),
          data: { disable_with: "Please wait..." },
          method: :post %>
      <hr />
    <% end %>
  <% else %>
    <% if User.current.roles.any? && (User.current.roles_for_project(@issue.project).map(&:id).to_a.map(&:to_s) & Setting.plugin_redmine_keywords['custom_field_role_ids'].to_a.map(&:to_s)).any? %>
      <% if Setting.plugin_redmine_keywords['custom_field_tracker_ids'].include?(@issue.try(:tracker_id).to_s)%>
        <%= button_to 'Check docs',
            check_files_path(id: @issue.id),
            data: { disable_with: "Please wait..." },
            method: :post %>
        <hr />
      <% end %>
    <% end %>
  <% end %>

EOS
