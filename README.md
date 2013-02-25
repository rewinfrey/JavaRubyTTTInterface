# TTT Web Interface

### About ###

This is a jRuby project using my [Java Web Server](https://github.com/rewinfrey/JavaWebServer) to serve my [Ruby TTT library](https://github.com/rewinfrey/ruby-ttt).

The server is included as a jar, the ruby library is included as a gem.

### Installation

You must have an installation of [jRuby](http://jruby.org/) with a jRuby binary located in usr/bin/ for the provided binary to work.

The version of jRuby used to develop this interface is jRuby-1.7.2. It is not tested on earlier versions of jRuby.

#### Biggest Hurdle

I wanted to learn about [Riak](http://basho.com/riak/), so I'm using Riak as the persistence layer for this library. If you want to use this interface, you'll need to install Riak.

If you're not interested in installing Riak from source && you are on OSX && you have [homebrew](http://mxcl.github.com/homebrew/), you can easily install Riak with the following:

`$ brew install riak`

Otherwise, please follow the Riak official installation [instructions](http://docs.basho.com/riak/latest/tutorials/installation/) for your OS.

After the Riak installation is complete, please ensure that your Riak instance is working:

`$ riak-admin ring-status`

You want to verify that your output says "All nodes are up and reachable":

    ================================== Claimant ===================================
    Claimant:  'dev1@127.0.0.1'
    Status:     up
    Ring Ready: true

    ============================== Ownership Handoff ==============================
    No pending changes.

    ============================== Unreachable Nodes ==============================
    All nodes are up and reachable

And also verify it is bound to the default Riak port (8091):

    $ curl -Is http://localhost:8091 > tmp; \
    ruby -e 'File.open("tmp") { |f| \
    if f.gets =~ (/200/i) then puts "We are in business" \
    else puts "Are you sure you got Riak installed?" end }'; \
    rm tmp

If you see "We are in business", then so far so good. Otherwise, there is a problem with the Riak installation.

#### Post Riak

Clone the repo:

`$ git clone git@github.com:rewinfrey/JavaRubyTTTInterface.git`

And bundle:

`$ cd JavaRubyTTTInterface`

`$ jruby -S bundle install`

### Usage

There is a binary provided that will start the server. You must provide the port you want the server to bind to.

`$ cd JavaRubyTTTInterface`

`$ bin/server -p 3010`

Or if more verbose is your thing:

`$ bin/server --port 3010`

You should now be able to point your browser to local host at the port you started the server on, and play Tic Tac Toe!
