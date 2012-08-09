module ApplicationHelper
  def authorized_for_job?(job, user)
    klass = job['payload']['class'].constantize
    klass.authorized?(*job['payload']['args'], user)
  end

	def show_flash_messages
		output = ""
    if flash[:notice]
      output << "<div class=\"alert alert-info\">#{flash[:notice]}</div>"
    end
    if flash[:error]
      output << "<div class=\"alert alert-error\">#{flash[:error]}</div>"
    end
    output
	end

  def show_tab_for( tab_id )
    unless session["#{tab_id}Show"].nil?
      tab = "$('##{tab_id} a[href=\"#{session["#{tab_id}Show"]}\"]').tab('show')"
      session["#{tab_id}Show"]=nil
      return tab
    end
  end
end
