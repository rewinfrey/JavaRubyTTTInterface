$:.unshift File.expand_path "../", __FILE__

require 'java'
require 'jar/httpServer.jar'
require 'bashrw-ttt'
require 'riak'

java_import Java::server.Responder
java_import Java::server.ServerUtils
java_import Java::server.HtmlGenerator
java_import Java::server.HttpServer

class TTTWebInterface
  attr_accessor :port, :directory, :http_server, :html_generator, :ttt_html_generator, :context, :presenter, :lib_interface

  def initialize(ttt_html_generator, presenter)
    self.ttt_html_generator = ttt_html_generator
    self.presenter          = presenter
  end

  def main()
    parse_options
    setup_interface
    self.http_server = HttpServer.new(self.port)
    register_routes()
    self.http_server.start()
  end

  def register_routes()
    self.http_server.registerRoute("/") { |request|
      response = java.util.HashMap.new
      body_string = new_game(context.players, context.boards)
      response.put("body", ServerUtils.convertStringToBytes(body_string))
      ServerUtils.putHeadersInResponseMap(response, request, "200 OK", "text/html", body_string.length())
      response
    }

    self.http_server.registerRoute("/new_game") { |request|
      response = java.util.HashMap.new
      body_string = new_game(context.players, context.boards)
      response.put("body", ServerUtils.convertStringToBytes(body_string))
      ServerUtils.putHeadersInResponseMap(response, request, "200 OK", "text/html", body_string.length())
      response
    }

    self.http_server.registerRoute("/create_game") { |request|
      response    = java.util.HashMap.new
      player1     = request.get("params").get("player1")
      player2     = request.get("params").get("player2")
      board       = request.get("params").get("board")
      game        = context.setup.new_game(:player1 => player1, :player2 => player2, :board => board)
      game_id     = context.add_game(game)
      body_string = show_game(game_id)
      response.put("body", ServerUtils.convertStringToBytes(body_string))
      ServerUtils.putHeadersInResponseMap(response, request, "200 OK", "text/html", body_string.length())
      response
    }

    self.http_server.registerRoute("/update_game") { |request|
      response    = java.util.HashMap.new
      game_id     = request.get("params").get("game_id")
      move        = request.get("params").get("move")
      side        = context.get_game(game_id).current_player.side

      context.update_game(game_id, move, side)

      body_string = show_game(game_id)
      response.put("body", ServerUtils.convertStringToBytes(body_string))
      ServerUtils.putHeadersInResponseMap(response, request, "200 OK", "text/html", body_string.length())
      response
    }

    self.http_server.registerRoute("/game_list") { |request|
      response    = java.util.HashMap.new
      games       = context.game_list
      body_string = ttt_html_generator.game_list(games)
      response.put("body", ServerUtils.convertStringToBytes(body_string))
      ServerUtils.putHeadersInResponseMap(response, request, "200 OK", "text/html", body_string.length())
      response
    }

    self.http_server.registerRoute("/move_next_history") { |request|
      response   = java.util.HashMap.new
      game_id    = request.get("params").get("game_id")
      body_string = move_history(game_id, 1)
      response.put("body", ServerUtils.convertStringToBytes(body_string))
      ServerUtils.putHeadersInResponseMap(response, request, "200 OK", "text/html", body_string.length())
      response
    }

    self.http_server.registerRoute("/move_prev_history") { |request|
      response   = java.util.HashMap.new
      game_id    = request.get("params").get("game_id")
      body_string = move_history(game_id, -1)
      response.put("body", ServerUtils.convertStringToBytes(body_string))
      ServerUtils.putHeadersInResponseMap(response, request, "200 OK", "text/html", body_string.length())
      response
    }

    self.http_server.registerRoute("/show_game") { |request|
      response = java.util.HashMap.new
      game_id  = request.get("params").get("game_id")
      body_string = show_game(game_id)
      response.put("body", ServerUtils.convertStringToBytes(body_string))
      ServerUtils.putHeadersInResponseMap(response, request, "200 OK", "text/html", body_string.length())
      response
    }

    self.http_server.registerRoute("/next_move") { |request|
      response = java.util.HashMap.new
      game_id  = request.get("params").get("game_id")
      context.ai_move(game_id)
      body_string = show_game(game_id)
      response.put("body", ServerUtils.convertStringToBytes(body_string))
      ServerUtils.putHeadersInResponseMap(response, request, "200 OK", "text/html", body_string.length())
      response
    }

    self.http_server.registerRoute("default") { |request|
      response = java.util.HashMap.new
      if (ServerUtils.isDirectory(directory + request.get("uri")))
          response = ServerUtils.directoryResponseGenerator(request, directory)
      elsif (ServerUtils.resourceExists(ServerUtils.expandFilePath(request.get("uri"), directory)))
          response = ServerUtils.fileResponseGenerator(request, directory)
      else
          response = ServerUtils.fourOhFourResponseGenerator(request)
      end
      response
    }
  end

  private
  def setup_interface
    self.context            = TTT::Context.instance
    self.context.setup      = TTT::Setup
    self.html_generator     = HtmlGenerator.new
    self.ttt_html_generator = TTTHtmlGenerator.new
    self.directory          = File.expand_path "../", __FILE__
  end

  def show_game(game_id)
    web_game_history   = get_history(game_id)
    web_game_presenter = presenter.for(get_game(game_id).board, game_id)
    flash_notice       = evaluate_game(game_id)
    ttt_html_generator.show_game(get_game(game_id), game_id, web_game_history, web_game_presenter, flash_notice)
  end

  def new_game(players, boards)
    body_string = self.ttt_html_generator.new_game(players, boards)
  end

  def parse_options
    options   = OptionParser.call
    self.port = options[:port].to_i
  end

  def get_history(game_id)
    context.get_history(game_id)
  end

  def save_move_traverser(game_id, move_traverser)
    context.save_move_traverser(game_id, move_traverser)
  end

  def get_game(game_id)
    context.get_game(game_id)
  end

  def get_move_traverser(game_id)
    context.get_move_traverser(game_id)
  end

  def get_history_builder(game_id, move_index_diff)
    move_traverser = get_move_traverser(game_id)
    move_traverser.adjust_move_index(move_index_diff.to_i)
    save_move_traverser(game_id, move_traverser)
    move_traverser.history_board_builder(get_game(game_id).board, move_traverser.move_index)
  end

  def move_history(game_id, move_index_diff)
    web_game_history   = get_history(game_id)
    game               = get_game(game_id)
    flash_notice       = evaluate_game(game_id)
    game.board.board   = get_history_builder(game_id, move_index_diff)
    web_game_presenter = presenter.for(game.board, game_id)
    ttt_html_generator.show_game(game, game_id, web_game_history, web_game_presenter, flash_notice)
  end

  def evaluate_game(game_id)
    if finished?(game_id) && winner?(game_id)
        winner = context.winner(game_id) + " is the winner!"
        return winner, "end_game"
    elsif finished?(game_id)
        return "It's a draw", "end_game"
    else
        player = context.which_current_player?(game_id) + "'s turn"
        return player, "show"
    end
end

  def get_history_length(game_id)
    context.get_history_length(game_id)
  end

  def get_history_board(game_id, move_index_diff)
    game           = context.get_game(game_id)
    move_traverser = game.history.move_traverser
    move_traverser.adjust_move_index(move_index_diff.to_i)
    move_traverser.history_board_builder(game.board, move_traverser.move_index)
  end

  def finished?(game_id)
    context.finished?(game_id)
  end

  def winner?(game_id)
    context.winner?(game_id)
  end
end

class OptionParser
  def self.call
    options = {}
    has_port = false

    ARGV.each_with_index do |arg, index|
      if arg == "-p" || arg == "--port"
        options[:port] = ARGV[index + 1]
        has_port = true
      elsif arg == "-h" || arg == "--help"
        help
      end
    end
    has_port ? options : help
  end

  def self.help
    printf("\n%2s", "Usage: bin/server [-p port]\n")
    printf("%-5s %-10s %s\n", "-p", "--port", "Choose the port you want the server to bind to")
    printf("%-5s %-10s %s\n\n", "-h", "--help", "Display this message")
    exit
  end
end
