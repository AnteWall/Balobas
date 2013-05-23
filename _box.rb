# -*- coding: utf-8 -*-
class Parser
  def _box(name="",statement="",func="")
  
    str = ""
    
    if(name != "")
      str += "<div class='"+name+"'>"
    else
      str += "<div>"
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

    str += "</div>"
    
    return str
  end

end
