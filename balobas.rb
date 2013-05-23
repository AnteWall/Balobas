#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require './parser_ground'
require './_box.rb'
require './_list.rb'
require './_item.rb'
require './_link.rb'
def return_string(data) 
  if data.class == String
    return data
  elsif data.class == Array && data.length > 0
    return return_string(data.inject do |result, element| result = result+return_string(element) end)
  end
  return ""
end


class Parser
  def getHTML()
    return @html
  end

  def getCSS()
    return @css_file
  end
end

class Balobas

  def initialize 
    
    @balobasParser = Parser.new("dice balobaer") do
      @html = Hash.new
      @html["head"] = []
      @html["body"] = []

      @variables = Hash.new
      @css_file = Hash.new

      token(/\n|\r/)
      token(/\[([a-zA-Z0-9\s]+)\]/){|m| m}
      token(/\s+/)
      token(/\d+/) {|m| m.to_i }
      token(/else if/){|m| m}
      token(/end\-box/){|m| m}
      token(/end\-if/){|m| m}
      token(/end\-iter/){|m| m}
      #Match a path
      token(/"[a-zA-Z0-9\/]+\.[a-zA-Z]+"/){|path|path}
      #match CSS - text with char or - followed by : and ends with ;
      token(/[A-z\-]+:[A-z0-9#\.\(\)\s%]+;\s*/){|m|m}
      #charsets
      token(/[a-zA-Z0-9]+[\-]+[a-zA-Z0-9]+/){|m|m}
      #varibles name
      token(/[a-zA-Z0-9]+[_]*[a-zA-Z0-9]*/){|m|m}


      token(/>=/){|m|m}
      token(/==/) {|m| m}
      token(/<=/) {|m| m}
      token(/>=/) {|m| m}
      token(/!=/) {|m| m}
      token(/@meta/){|m| m}
      token(/else/) {|m| m}

      token(/[a-zA-Z]+/){|m| m}
 
      token(/./) {|m| m }
      
      start :program do 
        match(:stmt_list) {|a| @html["body"] << a}
      end
      
      rule :stmt_list do 

        match(:stmt,:stmt_list){|n,m| n+m}
        match(:stmt)
      end

      rule :stmt do
        match(:list)
        match(:box)
        match(:include)
        match(:image)
        match(:meta)
        match(:body)
        match(:if)
        match(:var)
        match(:link)
        match(:text)
      end
      rule :expr do
        match(:boolean) {|bool| bool}
        match(:term,:operator,:term) do |term1, oper , term2|
          expr = term1.to_s + oper + term2.to_s
          eval(expr)
        end
        match(:term,:logic,:term) do |term1, logic, term2|
          logic = term1.to_s + logic + term2.to_s
          eval(logic)
        end
      end

      rule :name do
        match('#',String){|_,name| name}
      end

      rule :image do
        match('img','(',:path,'|',:string,')',:function) do |_,_,path,_,str,_,func|
          "<img src='#{path}' alt='#{str}' style='#{func}' />"
        end
        match('img','(',:path,'|',:string,')') do |_,_,path,_,str|
          "<img src='#{path}' alt='#{str}'/>"
        end
        match('img','(',:path,')',:function) do |_,_,path,_,func|
          "<img src='#{path}' style='#{func}' />"
        end
        match('img','(',:path,')') do |_,_,path,_|
          "<img src='#{path}'/>"
        end
      end

      rule :body do
        match('body',:function) do |_,func|
          @css_file["body"] = func
          ""
        end
      end

      #  _      _       _    
      # | |    (_)     | |   
      # | |     _ _ __ | | __
      # | |    | | '_ \| |/ /
      # | |____| | | | |   < 
      # |______|_|_| |_|_|\_\
                                            
      rule :link do
        match('link',:name,'(',:link_stmt,'|',:path,')',:function) do |_,name,_,str,_,path,_,func|
          _link(name,str,func,path)
        end
        match('link',:name,'(',:link_stmt,'|',:path,')',) do |_,name,_,str,_,path,_|
          _link(name,str,"",path)
        end
        match('link','(',:link_stmt,'|',:path,')',:function) do |_,_,str,_,path,_,func|
          _link("",str,func,path)
        end
        match('link','(',:link_stmt,'|',:path,')') do |_,_,str,_,path| 
          _link("",str,"",path)
        end
      end

      rule :link_stmt do
        match(:box)
        match(:var)
        match(:image)
        match(:string)
      end

      #  _____  __             ______ _          
      # |_   _|/ _|           |  ____| |         
      #   | | | |_   ______   | |__  | |___  ___ 
      #   | | |  _| |______|  |  __| | / __|/ _ \
      #  _| |_| |             | |____| \__ \  __/
      # |_____|_|             |______|_|___/\___|
                                                                                    
      rule :if do
        match('if','(',:expr,')',:stmt_list,:else_if)do |_,_,expr,_,stmt,f_expr|
          expr ? stmt : f_expr
        end
        match('if','(',:expr,')',:stmt_list,'end-if') {|_,_,expression,_,statement,_| expression ? statement : "" }
      end
      
      rule :else_if do
        match('else if','(',:expr,')',:stmt_list,:else_if) do |_,_,expr,_,stmt,f_expr|
          expr ? stmt : f_expr
        end
        match('else',:stmt_list,'end-if') { |_,stmt,_| stmt }
      end

      #  ____            
      # |  _ \           
      # | |_) | _____  __
      # |  _ < / _ \ \/ /
      # | |_) | (_) >  < 
      # |____/ \___/_/\_\
                 
      rule :box do
        match('box',:name,:function,:stmt_list,'end-box') do |_, name, func,statement,_ |
          _box(name,statement,func)
        end
        match('box',:name,:stmt_list,'end-box') do |_,name, statement, _| 
          _box(name,statement,"")
        end
        match('box',:function,:stmt_list,'end-box') do |_,func,statement,_|
          _box("",statement,func)
        end
        match('box',:stmt_list,'end-box') do|_,statement,_| 
          _box("",statement,"") 
        end
        match('box',:name,:function,'end-box') do |_,name,func,_| 
          _box(name,"",func)
        end
        match('box',:function,'end-box')do |_,func,_|
          _box("","",func)
        end
        match('box','end-box')do |_,_|
          _box("","","")
        end
      end

      #  _      _     _   
      # | |    (_)   | |  
      # | |     _ ___| |_ 
      # | |    | / __| __|
      # | |____| \__ \ |_ 
      # |______|_|___/\__|      
      
      rule :list do
        match('#','list',:name,:function,:item_list,'end-list') do |_, _, name, func,statement,_ |
          _list(name,statement,func)
        end
        match('#','list',:name,:item_list,'end-list') do |_,_,name, statement, _| 
          _list(name,statement,"")
        end
        match('#','list',:function,:item_list,'end-list') do |_,_,func,statement,_|
          _list("",statement,func)
        end
        match('#','list',:item_list,'end-list') do|_,_,statement,_| 
          _list("",statement,"") 
        end
        match('#','list',:name,:function,'end-list') do |_,_,name,func,_| 
          _list(name,"",func)
        end
        match('#','list',:function,'end-list')do |_,_,func,_|
          _list("","",func)
        end
        match('#','list','end-list')do
          _list("","","")
        end
      end

      #  _____ _                 
      # |_   _| |                
      #   | | | |_ ___ _ __ ___  
      #   | | | __/ _ \ '_ ` _ \ 
      #  _| |_| ||  __/ | | | | |
      # |_____|\__\___|_| |_| |_|
                                                    
      rule :item_list do
        match(:item,:item_list){|i1,i2| i1+i2 }
        match(:item)

      end
      rule :item do
        match('#','item',:name,:function,:stmt_list,'end-item') do |_, _, name, func,statement,_ |
          _item(name,statement,func)
        end
        match('#','item',:name,:stmt_list,'end-item') do |_,_,name, statement, _| 
          _item(name,statement,"")
        end
        match('#','item',:function,:stmt_list,'end-item') do |_,_,func,statement,_|
          _item("",statement,func)
        end
        match('#','item',:stmt_list,'end-item') do|_,_,statement,_| 
          _item("",statement,"") 
        end
        match('#','item',:name,:function,'end-item') do |_,_,name,func,_| 
          _item(name,"",func)
        end
        match('#','item',:function,'end-item')do |_,_,func,_|
          _item("","",func)
        end
        match('#','item',:name,'end-item')do |_,_,name|
          _item(name,"","")
        end
        match('#','item','end-item')do
          _item("","","")
        end
      end

      #  ______                _   _                 
      # |  ____|              | | (_)                
      # | |__ _   _ _ __   ___| |_ _  ___  _ __  ___ 
      # |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
      # | |  | |_| | | | | (__| |_| | (_) | | | \__ \
      # |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/

      rule :function do
        match(:function,'.',:function) {|f1,_,f2| f1+f2 }
        match('.',:style_list){|_,style| style}
        match(:style_list)
      end

      rule :style_list do
        match('css','(',:css,')') {|_,_,style,_|style}
        match(:size)
        match(:font)
        match('hover','(',:css,')')
        match('center') {|_| "margin:auto;"}
      end

      rule :css do
        match(:var)
        match(/[A-z\-]+:[A-z0-9#\.\(\)\s%]+;\s*/, :css) do |style,style2| 
          all_styles = ""
          all_styles += style
          all_styles += style2
          all_styles
        end
        match(/[A-z\-]+:[A-z0-9#\.\(\)\s%]+;\s*/){|m|m}
      end

      rule :size do
        match('size','(',:number,'%',',',:number,'%',')') do |_,_,x,_,_,y,_,_|
          size = "height:"+y.to_s+"%;"
          size += "width:"+x.to_s+"%;"
          size
        end
        match('size','(',:number,',',:number,'%',')') do |_,_,x,_,y,_,_|
          size = "height:"+y.to_s+"%;"
          size += "width:"+x.to_s+"px;"
          size
        end
        match('size','(',:number,'%',',',:number,')') do |_,_,x,_,_,y,_|
          size = "height:"+y.to_s+"px;"
          size += "width:"+x.to_s+"%;"
          size
        end
        match('size','(',:number,',',:number,')') do |_,_,x,_,y,_|
          size = "height:"+y.to_s+"px;"
          size += "width:"+x.to_s+"px;"
          size
        end
      end

      rule :font do
        match('font','(',:font_name,',',:number,')') do |_,_,f_name,_,size,_|
          f_css = "font-family: "+f_name+";"
          f_css += "font-size: "+size.to_s+"pt;"
        end
      end

      rule :font_name do
        match(/[\w\-\s\"]/,:font_name) {|s1,s2| s1+" "+s2 }
        match(/[\w\-\s\"]/)
      end

      rule :title do
        match('title','|',:var) do |_,_,title,_| 
          @html["head"] << "<title>#{title}</title>";"" 
        end
        match('title','|',:string) { |_,_,title| @html["head"] << "<title>#{title}</title>";"" }
      end

      rule :include do
        match('include','(',:path,')') do |_,_,pa|
          @html["head"] << "<script type='text/javascript' src="+pa+"></script>" 
          ""
        end
        match('include','(',:var_name) {|_,_,name| @html["head"] << "<script type='text/javascript' src="+name+"></script>";""}
      end

      #  __  __      _        
      # |  \/  |    | |       
      # | \  / | ___| |_ __ _ 
      # | |\/| |/ _ \ __/ _` |
      # | |  | |  __/ || (_| |
      # |_|  |_|\___|\__\__,_|
                       
      rule :meta do
        match('@meta','(','css','|',:path,')') do |_,_,_,_,src| 
          @html["head"] << "<link rel=\"stylesheet\" type=\"text/css\" href=\"#{src}\">";""
        end
        match('@meta','(',:title,')'){""}
        match('@meta','(',:charset,')'){""}
        match('@meta','(',:description,')'){""}
      end

      rule :charset do
        match('charset','|',/[a-zA-Z0-9\-]+/) do |_,_,char| 
          @html["head"] << "<meta charset='#{char}'>";""
        end
      end

      rule :path do
        match(/[a-zA-Z0-9\/]+\.[A-Za-z]+/){|s| s.gsub(/"/,"")}
      end

      rule :description do
        match('desc','|',:string) do |_,_,text|
          @html["head"] << "<meta name='description' content='#{text}' />"
          ""
        end
      end
      
      #  _______        _   
      # |__   __|      | |  
      #    | | _____  _| |_ 
      #    | |/ _ \ \/ / __|
      #    | |  __/>  <| |_ 
      #    |_|\___/_/\_\\__|                     
                     
      rule :text do
        match('[',:var,']',:function) do |_,text,_,func| 
          "<p style='"+func+"'>"+text+"</p>"
        end
        match('[',:var,']') do |_,text,_| 
          "<p>"+text+"</p>"
        end
        match(/\[([a-zA-Z0-9\s]+)\]/,:function) do |s,func|
          "<p style='#{func}'>"+s.gsub(/^\[/,"").gsub(/\]$/, "")+"</p>"
        end
        match(/\[([a-zA-Z0-9\s]+)\]/) do |s| 
          "<p>"+s.gsub(/^\[/,"").gsub(/\]$/, "")+"</p>"
        end
      end

      rule :term do
        match(:var)
        match(:number)
        match(:boolean)
      end

      rule :operator do
        match('*')
        match('/')
        match('%')
        match('+')
        match('-')
      end

      rule :logic do
        match('<') {|m| m}
        match('>') {|m| m}
        match('==') {|m| m}
        match('<=') {|m| m}
        match('>=') {|m| m}
        match('!=') {|m| m}
      end
      


      # __      __        _       _     _           
      # \ \    / /       (_)     | |   | |          
      #  \ \  / /_ _ _ __ _  __ _| |__ | | ___  ___ 
      #   \ \/ / _` | '__| |/ _` | '_ \| |/ _ \/ __|
      #    \  / (_| | |  | | (_| | |_) | |  __/\__ \
      #     \/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/
      #      

      rule :var do
        match(:var_assign)
        match(:var_get)
      end

      rule :var_assign do
        match(:var_name,'=',:expr) do |name,_,value|
          @variables[name] = value.to_s;
          ""
        end
        match(:var_name,'=','"',:string,'"'){|name,_,_,value,_| @variables[name] = value; ""}
        match(:var_name,'=',:number){|name,_,value| @variables[name] = value.to_s; ""}
        match(:var_name,'=',:boolean){|name,_,value| @variables[name] = value; ""}
      end

      rule :var_get do
        match('§',/[a-zA-Z0-9]+[_]*[a-zA-Z0-9]*/){|_,name| @variables[name] }
      end

      rule :var_name do
        match('§',/[a-zA-Z0-9]+[_]*[a-zA-Z0-9]*/){|_,name| name }
      end
      
      # __      __          _______                    
      # \ \    / /         |__   __|                   
      #  \ \  / /_ _ _ __     | |_   _ _ __   ___  ___ 
      #   \ \/ / _` | '__|    | | | | | '_ \ / _ \/ __|
      #    \  / (_| | |       | | |_| | |_) |  __/\__ \
      #     \/ \__,_|_|       |_|\__,_| .__/ \___||___/
      #                               | |              
      #                               |_|              

      rule :number do
        match(Integer)
      end
      
      rule :string do
        match(/[a-zA-Z0-9]+/,:string){|s1,s2| s1+" "+s2}
        match(/[a-zA-Z0-9]+/)
      end

      rule :boolean do
        match(/false/) {false}
        match(/true/) {true}
      end

    end
  end
    
  def baloba(filename,gen_file)
    f = File.read(filename)
    str = f
    log(false)
    puts "=> #{@balobasParser.parse str}"
    
 
    html_code = "<body>"
    head_code = "<html><head>"
    css = ""
    
    ### Add all the Head code to document ###
    @balobasParser.getHTML()["head"].each do |r|
      head_code = head_code + return_string(r)
    end
    # Add last head tag
    head_code = head_code + "</head>"

    ### Add all the Html code to body ###
    @balobasParser.getHTML()["body"].each do |r|
     html_code = html_code + return_string(r)
    end
    # Add last body and html tag
    html_code = html_code + "</body>\n</html>"

    ### Add all the css code to css file """
    @balobasParser.getCSS().each do |k,v|
      if(k == "body")
        css_rule = k+"{"+v+"}"
      elsif
        css_rule = '.'+k+"{"+v+"}"
      end
      css = css + css_rule
    end
    #small reset of all elements in css - for multiply webbrowser
    css = css + "*{margin:0;padding:0;border:0;}"
    # Write to files
    File.open(gen_file,"w"){|f| f.write(head_code+html_code)} 
    File.open("style.css","w"){|f| f.write(css)} 
    
  end

  def log(state = true)
    if state
      @balobasParser.logger.level = Logger::DEBUG
    else
      @balobasParser.logger.level = Logger::WARN
    end
  end
end



if(ARGV[1] == nil)
  puts "Needs 2 arguments - Inputfile and Outputfile"
else
  file = ARGV[0]
  gen_file = ARGV[1]
  puts "Starting..."
  Balobas.new.baloba(file,gen_file)
  puts "Complete! Generated '#{gen_file}' from '#{file}'"
end


