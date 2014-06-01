Noobie on Nails
===============

I made this with [Matt Long](https://github.com/wismer/) for the first week of Amy Hanlon's [Iron Forger](http://mathamy.com/introducing-iron-maker-or-forger-or-something.html) challenge.

The Router class defines mappings of urls to functions.  The Server class parses incoming http requests, and constructs an http response with one of the following as the content:

1. If the requested url is in the server's router, it will call the associated function, which takes a hash of any arguments captured from the url and returns a string
2. If the requested url is a path to a file in root/, the file will be read and served
3. If the requested url is a path to a directory in root/, and that directory has a file named index.html, that file will be read and served
4. If none of the previous cases apply, root/not-found.html will be served.

You can test this out by cloning this repo and running `ruby app.rb`.  Then you can view the sample files and routes by navigating to:

`localhost:9393/static.html` (fetches root/static.html)
`localhost:9393/` (fetches root/index.html)
`localhost:9393/posts` (fetches root/posts/index.html)
`localhost:9393/bleep` (calls the function bound to bleep in app.rb)
`localhost:9393/greet/yourname` (greets a user named yourname, as defined in app.rb)

Feel free to play around with it; pull requests are welcome.
