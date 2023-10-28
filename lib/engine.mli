type player = X | O
type hpos = H of int
type vpos = V of int
type pos = hpos * vpos
type board = player option list list

module Pos : sig
  val h : int -> hpos
  val v : int -> vpos
end

(* Pretty printers *)

val pp_player : Format.formatter -> player option -> unit
val pp_hpos : Format.formatter -> hpos -> unit
val pp_vpos : Format.formatter -> vpos -> unit
val pp_board : Format.formatter -> board -> unit
val equal_hpos : hpos -> hpos -> bool
val equal_vpos : vpos -> vpos -> bool
val equal_pos : pos -> pos -> bool
val equal_player : player option -> player option -> bool
val equal_board : board -> board -> bool
val equal_list_player : player option list -> player option list -> bool

exception Invalid_xpos
exception Invalid_ypos
exception Invalid_move

val init : player option list list -> board
val new_board : board

(* [get board pos] return the state of the [board] at the given position [pos]. *)
val get : board -> pos -> player option

(* [set board pos player] puts the [player]'s mark at the given position [pos] of the [board]. *)
val set : board -> pos -> player -> board

module Verif : sig
  val win : board -> player -> bool
  val move : board -> player -> pos -> bool
  val can_play : board -> player -> bool
end
