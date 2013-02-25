# TTT Web Interface

### About ###

This is a jRuby project using my [Java Web Server](https://github.com/rewinfrey/JavaWebServer) to serve my [Ruby TTT library](https://github.com/rewinfrey/ruby-ttt). The server is included as a jar, the ruby library is included as a gem.

### Installation

You must have an installation of jRuby with the jRuby binary added to your usr/bin/env path. The version of jRuby used to develop this interface is jRuby-1.7.2. It is not tested on earlier versions of jRuby.

The current implementation has a dependency on the Riak database.

To install Riak, please follow these [instructions](http://docs.basho.com/riak/latest/tutorials/installation/)

After the Riak installation is complete, please ensure that your Riak instance is bound to the default port, 8091.

And then clone the repo:

$ git clone git@github.com:rewinfrey/JavaRubyTTTInterface.git

And bundle:

$ cd JavaRubyTTTInterface

$ jruby -S bundle install

### Usage

There is a binary provided that will start the server. You must provide the port you want the server to bind to.

$ cd JavaRubyTTTInterface

$ bin/server -p 3010

or if more verbose is your thing:

$ bin/server --port 3010

You should now be able to point your browser to local host at the port you started the server on, and play Tic Tac Toe!
