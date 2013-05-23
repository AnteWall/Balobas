#-*- coding: utf-8 -*-
class Parser
  def _link(name="",statement="",func="",href="")
  
    str = ""
    
    if(name != "")
      str += "<a class='"+name+"'>"
    else
      str += "<a>"
    end
     
    if(name == "" && func != "")
      str = str[0..-2]
      str += " style='"+func+"'>"
    elsif(func != "")
      @css_file[name] = return_string(func)
    end

    if(href != "")
      str = str[0..-2]
      str += " href='"+return_string(href)+"'>"
    end

    if(statement != "")
      str += return_string(statement)
    end



    str += "</a>"
    
    return str
  end
end
