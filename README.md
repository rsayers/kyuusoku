Kyuusoku
========

Kyuusoku (Japanese for Quick) is  minimal Ruby/CGI Wiki.  I wanted a very simple wiki to manage my personal homepage, but found existing CGI solutions were too big or outdated.  Most Ruby wikis these days depend on Rack at the very least, and are often full blown Rails apps.

Kyuusoku is written by Rob Sayers (http://www.robsayers.com) and is released to the public domain.

Dependencies
------------
Ruby 1.8+, Ruby CGI, Erb, BlueCloth

Installation
------------

Copy kyuusoku.rb to the place on your web server where it will live,  make sure it's setup according to your hosting environment's rules.  In my case, I've renamed it to index.cgi and made it executable.

Then edit the config hash at the top of the file to reflect your own settings.  Make sure that the script can both read and write the datafile.  Go to the appropriate URL and you should be greeted with a blank homepage which you can start editing.

Editing
-------

Aside from the config at the top of the file, you can also edit the templates at the bottom of the file.  These are Sinatra style where they have a title preceeded with two "at" symbols.  The get_template function will return the appropriate template as a string.  All templates are processed in ERB.  Content placed in the wiki is parsed as markdown by default, but swapping out your formatter of choice is trivial.


