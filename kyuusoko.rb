#!/usr/local/bin/ruby
require 'cgi'
require 'rubygems'
require 'bluecloth'
require 'erb'

### Edit this hash to setup your wiki ###
config = {
  'datafile'=>'./data',
  'title'=>'My Wiki Title',
  'index'=>'Home',
  'password'=>'password',
  'path'=>'/kyuusoko.rb'
}

def get_template name
  DATA.seek(0,0)
  DATA.read.split("@@").find{ |x| x.split("\n")[0]==name }.split("\n")[1..-1].join("\n")
end

cgi = CGI.new
if ENV['PATH_INFO'] then
  blank,operation, page =  ENV['PATH_INFO'].split('/')
end
text, pass  = cgi['t'], cgi['pass']

### If operation is nil, we can assume you hit the base url,  lets feed you the default page
if (operation.nil? || operation=='') then
  operation = 'view'
  page = config['index']
end

### Load the data file if it exists
data = File.exist?(config['datafile']) ? Marshal.load(open(config['datafile']).read)  : {}
if !text.nil? && text.length > 0 then
  data[page] = text
  if (config['password'].nil? || pass==config['password']) then
    File.open(config['datafile'],'w') do |f|
      Marshal.dump(data, f)
    end
  end
end

puts "Content-type: text/html\n\n"
content = ERB.new(get_template(operation)).result
puts ERB.new(get_template('main')).result
__END__


@@main
<!DOCTYPE html>
  <html>
  <head>
  <title><%=page%></title>
  <style>
    body {
      color: #222;
      background: #fff;
      font-family: "Helvetica Neue", Arial, Helvetica, sans-serif;
    }

    h1,h2,h3,h4,h5,h6 { font-weight: normal; color: #111; }

    textarea {
      width: 90%;
      height: 600px;
    }
  </style>
  <head>
  <body>
    <%=content%>
  </body>
</html>

@@edit
     <form action="<%=config['path']%>/view/<%=page%>" method="post">
     <h1><%=page%></h1>
     <textarea rows="10" name="t"><%=data[page]%></textarea><br>
     <% if !config['password'].nil? then %> Password: <input name="pass" type="password"> <% end %>
     <hr><input type="submit" value="Save"></form>
@@view
<h1><%=page%></h1>
<hr>
<%=BlueCloth.new(data[page]).to_html%>
<hr>
<a href="<%=config['path']%>/edit/<%=page%>">Edit <%=page%></a>
