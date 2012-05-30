module ApplicationHelper
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
end
