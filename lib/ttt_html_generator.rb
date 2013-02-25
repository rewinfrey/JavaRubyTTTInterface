  class TTTHtmlGenerator
    def new_game(player_types, board_types)
      html_string = html_open
      html_string += %q[<div style="margin: 100px;">]
      html_string += %q[<h1>New Game</h1><form action="create_game" method="post" accept-charset="UTF-8">]
      html_string += %q[<div class="form_div"><label class="form_label">Player 1 Type:</label><select class="form_select" id="player1" name="player1">]
      player_types.each do |player_option|
        html_string += "<option>#{player_option}</option>"
      end
      html_string += %q[</select></div>]
      html_string += %q[<div class="form_div"><label class="form_label">Player 2 Type:</label><select class="form_select" id="player2" name="player2">]
      player_types.each do |player_option|
        html_string += "<option>#{player_option}</option>"
      end
      html_string += %q[</select></div>]
      html_string += %q[<div class="form_div"><label class="form_label">Board Type:</label><select class="form_select" id="board", name="board">]
      board_types.each do |board_option|
        html_string += "<option>#{board_option}</option>"
      end
      html_string += %q[</select></div>]
      html_string += %q[<div style="width: 95px; margin: 10px auto 0 auto;"><input class="button" name="commit" type="submit" value="Submit"></div></form></div>]
      html_string += html_close
    end

    def show_game(game, game_id, web_game_history, web_game_presenter, flash_notice)
        html_string = html_open
        html_string += hidden_field(game, game_id, flash_notice)
        html_string += move_index(web_game_history)
        html_string += main_body(flash_notice, web_game_presenter)
        html_string += move_history if flash_notice.last == "end_game"
        html_string += html_close
    end

    def end_game()
    end
    def game_list(games)
        html_string = html_open
        html_string += %q[<h1>Select A Game</h1><table style="width: 640; margin: auto;"><tr>]
        games.each_with_index do |id, index|
            html_string += "</tr><tr>" if index % 10 == 0
            html_string += %Q(<td id="#{index}" style="width: 50px; height: 50px; text-align: right;">)
            html_string += %Q(<a href="/show_game?game_id=#{id}">#{id}</a></td>)
        end
        html_string += %q[</tr></table>]
        html_string += html_close
    end

    def hidden_field(game, game_id, flash_notice)
      html_string = ""
      html_string += %Q[<div id="current_player" game_id=#{game_id}>]
      html_string += "true" if game.ai_move? && !game.board.finished? && flash_notice[1] != "end_game"
      html_string += "</div>"
    end

    def main_body(flash_message, web_game_presenter)
      html_string = ""
      html_string += %q[<div style="width: 1020px; margin: 100px auto 20px auto;">]
      html_string += %Q(<h4 class="notice">#{flash_message.first}</h4>) if flash_message
      html_string += web_game_presenter.show_board
      html_string += %q[</div>]
    end

    def move_history
      html_string = ""
      html_string += %q[<div id="buttons" style="width: 800px; margin: auto;">]
      html_string += %q[<div id="button_left" style="float: left; margin-left: 200px;">]
      html_string += %q[<img src="public/images/button_left.png" class="pointer" /></div>]
      html_string += %q[<div id="button_right" style="float: right; margin-right: 200px;">]
      html_string += %q[<img src="public/images/button_right.png" class="pointer" /></div></div>]
    end

    def move_index(web_game_history)
      html_string = ""
      html_string += %q[<div class="move_history" style="float: right; width: 170px; height: 800px; text-align: right;">]
      html_string += %q[<h4 style="text-align: center;">Move History</h4>]
      html_string += %q[<ul style="width: 215px;">]
      web_game_history.each_with_index do |move, index|
        move_list_class = index == 0 ? "move_list_first" : "move_list"
        html_string += %Q(<li class="#{move_list_class}"><span style="margin-right: 10px;">#{index + 1}.</span><span style="margin-right: 10px;">#{move.side}</span> #{move.move}</li>)
      end
      html_string += %q[</ul></div>]
    end

    def html_open
      html_string = ""
      html_string += %q[<!DOCTYPE html>]
      html_string += %q[<html><head><title>Java Server TTT</title>]
      html_string += %q[<link href="public/images/favicon.ico" rel="shortcut icon" type="image/vnd.microsoft.icon" />]
      html_string += %q[<link href="public/css/tictactoe.css" media="all" rel="stylesheet" type="text/css" />]
      html_string += %q[<script src="public/js/jquery.js" type="text/javascript"></script>]
      html_string += %q[<script src="public/js/ttt.js" type="text/javascript"></script>]
      html_string += %q[<body><div class="main_buttons"><div class="new_game_btn_wrapper">]
      html_string += %q[<a href="new_game" class="button">New Game</a></div>]
      html_string += %q[<div class="all_games_btn_wrapper">]
      html_string += %q[<a href="game_list" class="button">All Games</a></div>]
      html_string += %q[</div>]
    end

    def html_close
      "</body></html>"
    end
  end
