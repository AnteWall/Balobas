#-*- coding: utf-8 -*-
class Parser
  def _item(name="",statement="",func="")
  
    str = ""
    
    if(name != "")
      str += "<li class='"+name+"'>"
    else
      str += "<li>"
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

    str += "</li>"
    
    return str
  end

end
