§title_text = "Balobas Exempel"
@meta(title|§title_text)
@meta(css|"style.css")
@meta(charset|utf-8)
@meta(desc|Detta ar en exempelsida)
body.css(background: #000;)
include("js/scripts.js")

§year = 2013

box#topbar.size(100%,40).css(background:#ff5400;)
        [Balobas].css(padding:10px;text-transform:uppercase;color:white;font-weight:bold;)

end-box

box#container.size(800,800).center.css(background:#cfcfcf;margin-top:10px;)
        #list#nav.css(list-style-type:none;)
                      
		#item#i.size(198,80).css(background:#FF4200;text-align:center;line-height:80px;float:left;position:relative;border:1px solid #FF5400;)
                link#navlink(Hej dasjisa|"hej.html").css(color:white;position:absolute;top:0;left:0;text-decoration:none;).size(100%,100%)
		end-item
                #item#i
                        link#navlink(Profile|"profile.html")
                end-item
                #item#i
                        link#navlink(Contact|"contact.html")
                end-item
                #item#i
                        link#navlink(Other|"other.html")
                end-item
        end-list

        link(img("bild.jpg" |Detta ar alt text).center.css(display:block;)|"bild.jpg")

        if(§year > 2012)
                 [We did not die]
        else
                 [Dammit]
        end-if
end-box
