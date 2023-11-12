open Engine

type trace = (hpos * vpos) list
type endplay = Win of player | Giveup of player | Draw

let pp_trace fmt t = List.iter (fun p -> Format.fprintf fmt "%a " pp_pos p) t
let equal_trace (t1 : pos list) (t2 : pos list) = t1 = t2
(*List.equal equal_pos t1 t2*)

let pp_endplay fmt ep =
  match ep with
  | Win p -> Format.fprintf fmt "%a won the game" pp_player (Some p)
  | Giveup p -> Format.fprintf fmt "%a gave up :(" pp_player (Some p)
  | _ -> Format.fprintf fmt "Draw"

let equal_endplay e1 e2 = e1 = e2
let check_pos board (h, v) = List.exists (equal_pos (h, v)) (free_pos board)
let player_function player f_p1 f_p2 = match player with X -> f_p1 | _ -> f_p2

let endgame board trace status =
  Format.printf "@[<v>%a@]@," pp_endplay status;
  Format.printf "board : @[<v>%a@]@." pp_board board;
  Format.printf "trace : @[<v>%a@]@." pp_trace trace;
  ()

let rec play (player : player) (board : board)
    (f_player : player -> board -> (hpos * vpos) option) (trace : trace) =
  let open Engine.Verif in
  let choice = f_player player board in

  match choice with
  | None -> (board, trace)
  | Some p ->
      if check_pos board p then
        let to_change = move board (Some player) p in
        if List.length to_change = 1 then play player board f_player trace
        else (set board player to_change, List.append trace [ p ])
      else play player board f_player trace

(*player 1 : X | player 2 : O*)
let game function_player1 function_player2 init_board =
  let open Verif in
  let rec go board player function_player1 function_player2 (trace : trace) =
    let current_function =
      player_function player function_player1 function_player2
    in
    let current_player = swap_player player in
    let new_board, new_trace =
      play current_player board current_function trace
    in
    if equal_board board new_board then
      endgame board trace (Giveup current_player)
    else if win new_board player && win new_board current_player then
      endgame new_board new_trace Draw
    else if win new_board player then endgame new_board new_trace (Win player)
    else if win new_board current_player then
      endgame new_board new_trace (Win current_player)
    else go new_board current_player function_player1 function_player2 new_trace
  in
  go init_board O function_player1 function_player2 []

let player_teletype p b =
  Format.printf "@[<v>It's player %a's turn.@," pp_player (Some p);
  Format.printf "Board:  @[<v>%a@]@," pp_board b;

  Format.printf "Choose your move : @]@.";
  try
    Scanf.scanf "%c%d\n" (fun i j ->
        Some (Pos.h (int_of_char i - int_of_char 'A'), Pos.v j))
  with Scanf.Scan_failure _ -> None

let player_random p b =
  let open Verif in
  let listOfMov = possible_move_list p b in
  if List.length listOfMov > 0 then
    Some (List.nth listOfMov (Random.int (List.length listOfMov)))
  else None

let player_giveup p b =
  ignore (p, b);
  None
