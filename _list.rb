# -*- coding: utf-8 -*-
class Parser
  def _list(name="",statement="",func="")
  
    str = ""
    
    if(name != "")
      str += "<ul class='"+name+"'>"
    else
      str += "<ul>"
    end
     
    if(name == "" && func != "")
      str = str[0..-2]
      str += " style='"+func+"'>"
    elsif(func != "")
      @css_file[name] = return_string(func)
    end

    if(statement != "")
      str += return_string(statement)
    end

    str += "</ul>"
    
    return str
  end

end
