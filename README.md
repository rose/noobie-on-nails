Noobie on Nails
===============

I made this with [Matt Long](https://github.com/wismer/) for the first week of Amy Hanlon's [Iron Forger](http://mathamy.com/introducing-iron-maker-or-forger-or-something.html) challenge.

The Router class defines mappings of urls to functions.  The Server class parses incoming http requests, and constructs an http response with one of the following as the content:

1. If the requested url is in the server's router, it will call the associated function, which is assumed to return a string
2. If the requested url is a path to a file in root/, the file will be read and served
3. If the requested url is a path to a directory in root/, and that directory has a file named index.html, that file will be read and served
4. If none of the previous cases apply, root/not-found.html will be served.

App.rb contains an example of how to construct routes, insert them into a router, and create & run a server.  Try defining more routes in it, and/or adding some files to the root directory, then start the app with `ruby app.rb` and point your browser at `localhost:9393` to view the results.
