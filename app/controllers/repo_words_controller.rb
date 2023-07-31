class RepoWordsController < ApplicationController
  def check_files
    @issue = Issue.all.find_by_id(params[:id])
    hook_params = { params: params, issue: @issue }
    call_hook(:controller_issues_after_click, hook_params)
    redirect_to @issue
  end
end
