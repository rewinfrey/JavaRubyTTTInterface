$(document).ready( function(){
  $('td.human').click(mark_move);
  $('td.game_list').click(show_game);
  $('.current_player').bind(next_move);
  $('#button_right').click(next_history_move);
  $('#button_left').click(prev_history_move);
  window.setTimeout( function() { next_move()}, 1500);
});

function mark_move() {
  id = $(this).attr("value");
  $("#"+id+"").submit();
}

function show_game() {
  console.log("here!");
  id = $(this).attr("value");
  $("#"+id+"").submit();
}

function next_move() {
  val = $('#current_player').html();
  if (val != undefined && val.trim() == "true") {
    id = $('#current_player').attr('game_id');
    window.location = "/next_move?game_id="+id;
  }
}

function prev_history_move() {
  console.log(find_id());
  window.location = "/move_prev_history?game_id=" + find_id();
}

function next_history_move() {
  console.log(find_id());
  window.location = "/move_next_history?game_id=" + find_id();
}

function find_id() {
  return $('#current_player').attr('game_id');
}
