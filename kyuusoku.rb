#!/usr/local/bin/ruby
require 'cgi'
require 'rubygems'
require 'bluecloth'
require 'erb'
require 'date'
require 'yaml'


### Edit this hash to setup your wiki ###
config = {
  'datafile'=>'./data.yaml',
  'title'=>'My Wiki',
  'index'=>'Home',
  'password'=>'',
  'path'=>'/kyuusoku.rb'
}

def get_template name
  $stderr.puts "getting template #{name}"
  DATA.seek(0,0)
  DATA.read.split("@@").find{ |x| x.split("\n")[0]==name }.split("\n")[1..-1].join("\n")
end

class Revision
      attr_accessor :text, :datetime
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
data = File.exist?(config['datafile']) ? YAML.load_file(config['datafile'])  : {}
data = data ? data : {}
$stderr.puts data
if !text.nil? && text.length > 0 then
  data[page] = [] if data[page].nil?
  rev = Revision.new
  rev.text = text
  rev.datetime = DateTime.now
  data[page] << rev
  if (config['password'].nil? || pass==config['password']) then
    File.open(config['datafile'],'w') do |f| 
      f.write(data.to_yaml)
    end
  end
end

if data[page].nil? then
   rev = Revision.new
   rev.text=""
   rev.datetime = DateTime.now
   data[page]=[rev]
end

current_page = data[page].last

puts "Content-type: text/html\n\n"
content = ERB.new(get_template(operation)).result
puts ERB.new(get_template('main')).result

__END__

@@main
<!DOCTYPE html>
  <html>
  <head>
  <meta charset="utf-8" />
  <title><%=page%></title>
  <style>
    body {
      color: #222;
      background: #e6e6e6;
      font-family: "Helvetica Neue", Arial, Helvetica, sans-serif;
    }
    h1,h2,h3,h4,h5,h6 { font-weight: normal; color: #515151; }
    a { color: #aaa; }
    textarea {
      width: 90%;
      height: 600px;
    }

    #container { 

      padding: 10px; 
      background: #fff;
      width: 90%;
      margin-left: auto;
      margin-right: auto;
box-shadow: 0 2px 6px rgba(100, 100, 100, 0.3);
}   
  </style>
  </head>
  <body>
  <div id="container">
    <%=content%>
    </div>  
  </body>
</html>

@@edit
     <form action="<%=config['path']%>/view/<%=page%>" method="post">
     <h1>Editing: <%=page%></h1>
     <textarea rows="10" name="t"><%=current_page.text %></textarea><br>
     <% if !config['password'].nil? then %> Password: <input name="pass" type="password"> <% end %>
     <hr><input type="submit" value="Save"></form>
@@view
<h1><a href="<%config['path']%>/view/<%=config['index']%>"><%=config['title']%></a> :: <%=page%></h1>
<hr>
<%=BlueCloth.new(current_page.text).to_html%>
<hr>
<a href="<%=config['path']%>/edit/<%=page%>">Edit <%=page%></a> | Last modified: <%=current_page.datetime.strftime("%Y-%m-%dT%H:%M:%S%z")%>
