require 'spec_helper'

describe TTTWebInterface do

  let(:ttt_html_generator) { TTTHtmlGenerator.new }
  let(:presenter)          { WebGamePresenter }

  let(:subject) { TTTWebInterface.new(ttt_html_generator, presenter) }

  describe "main" do
    it "parses the command line options" do
      allow_message_expectations_on_nil
      subject.should_receive(:parse_options)
      subject.stub(:setup_interfaces)
      HttpServer.stub(:new)
      subject.stub(:register_routes)
      subject.http_server.stub(:start)
      subject.main
    end

    it "setups up the interface" do
      allow_message_expectations_on_nil
      subject.stub(:parse_options)
      subject.should_receive(:setup_interface)
      HttpServer.stub(:new)
      subject.stub(:register_routes)
      subject.http_server.stub(:start)
      subject.main
    end

    it "creates a new HttpServer instance" do
      allow_message_expectations_on_nil
      subject.stub(:parse_options)
      subject.stub(:setup_interfaces)
      HttpServer.should_receive(:new)
      subject.stub(:register_routes)
      subject.http_server.stub(:start)
      subject.main
    end

    it "registers routes" do
      allow_message_expectations_on_nil
      subject.stub(:parse_options)
      subject.stub(:setup_interfaces)
      HttpServer.stub(:new)
      subject.should_receive(:register_routes)
      subject.http_server.stub(:start)
      subject.main
    end

    it "starts the server" do
      allow_message_expectations_on_nil
      subject.stub(:parse_options)
      subject.stub(:setup_interfaces)
      HttpServer.stub(:new)
      subject.stub(:register_routes)
      subject.http_server.should_receive(:start)
      subject.main
    end
  end

  describe "register_routes" do
    it "sets the routes the server responds to" do
      allow_message_expectations_on_nil
      subject.http_server.should_receive(:registerRoute).with("/")
      subject.http_server.should_receive(:registerRoute).with("/new_game")
      subject.http_server.should_receive(:registerRoute).with("/create_game")
      subject.http_server.should_receive(:registerRoute).with("/update_game")
      subject.http_server.should_receive(:registerRoute).with("/game_list")
      subject.http_server.should_receive(:registerRoute).with("/move_next_history")
      subject.http_server.should_receive(:registerRoute).with("/move_prev_history")
      subject.http_server.should_receive(:registerRoute).with("/show_game")
      subject.http_server.should_receive(:registerRoute).with("/next_move")
      subject.http_server.should_receive(:registerRoute).with("default")
      subject.register_routes
    end

    context "each route returns a response" do
      before(:all) {
        @interface = TTTWebInterface.new(ttt_html_generator, presenter)
        @interface.stub(:parse_options)
        @port = 8888
        @interface.port = @port
        @interface.main
      }

      after(:all) {
        return
      }

      describe "/ route" do
        it "returns a 200 OK text/html response" do
          response = StringIO.new(`curl -I http://localhost:8888`)
          response.gets.should == "HTTP/1.1 200 OK\r\n"
        end
      end

      describe "/new_game" do
        it "returns a 200 OK text/html response" do
          response = StringIO.new(`curl -I http://localhost:8888/new_game`)
          response.gets.should == "HTTP/1.1 200 OK\r\n"
        end
      end

      describe "/create_game" do
        it "does not return an error after posting" do
          response = StringIO.new(`curl -d "player1=Human&player2=Human&board=3x3" http://localhost:8888/create_game`)
          response.string.match("error404").should be_nil
        end
      end

      describe "/update_game" do
        it "does not return an error after posting" do
          response = StringIO.new(`curl -d "game_id=1&move=0" http://localhost:8888/update_game`)
          response.string.match("error404").should be_nil
        end
      end

      describe "/game_list" do
        it "returns a 200 OK text/html response" do
          response = StringIO.new(`curl -I http://localhost:8888`)
          response.gets.should == "HTTP/1.1 200 OK\r\n"
        end
      end

      describe "/move_next_history" do
        it "returns a 200 OK text/html response" do
          response = StringIO.new(`curl -d "game_id=1" http://localhost:8888/move_next_history`)
          response.string.match("error404").should be_nil
        end
      end

      describe "/move_prev_history" do
        it "returns a 200 OK text/html response" do
          response = StringIO.new(`curl -d "game_id=1" http://localhost:8888/move_prev_history`)
          response.string.match("error404").should be_nil
        end
      end

      describe "/show_game" do
        it "returns a 200 OK text/html response" do
          response = StringIO.new(`curl -I http://localhost:8888/show_game?game_id=1`)
          response.gets.should == "HTTP/1.1 200 OK\r\n"
        end
      end

      describe "/next_move" do
        it "returns a 200 OK text/html response" do
          response = StringIO.new(`curl -I http://localhost:8888/next_move?game_id=1`)
          response.gets.should == "HTTP/1.1 200 OK\r\n"
        end
      end
    end
  end
end

