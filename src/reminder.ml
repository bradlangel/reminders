open Core.Std
open Async.Std

(* TODO:
   Things to add:
   1. First notification should occur a couple of weeks prior to event
   date. Then notifications should increase as the event draws nearer. I.e. one
   per day 3 days prior to event-date.
   2. Better output-message that includes date of event.
   3. Do not use Csv.x throughout code; separate by creating record of row.
   X. Send notification via email or text...
   X+1. Support for other types of events... *)

module Event = struct
  type t = | Bday
  let to_string t = function | Bday -> "Birthday"
  let of_string s =
    match String.lowercase s with
    | "bday" | "birthday" -> Bday
    | e -> failwithf "Unknown event: %s" e ()
end

let tap f x = f x; x

let is_today d =
  (* Compares the month and day of [d] with today's month and day.*)
  let to_month d = d |> Date.month |> Month.to_int in
  let today = Date.today ~zone:Core.Zone.local in
  (Date.day d = Date.day today) && (to_month d = to_month today)

let contains_reminders row =
  match Csv.Row.find row "date" with
  | "" -> false
  | date -> date |> Date.of_string |> is_today

let read_csv csv =
  Csv.of_string csv ~has_header:true ~strip:true
    ~header:(csv |> Csv.of_string ~has_header:true |> Csv.Rows.header)
  |> Csv.Rows.input_all

let prettify row =
  match Csv.Row.find row "event" |> Event.of_string with
  | Event.Bday ->
    let today = Date.today ~zone:Core.Zone.local |> Date.year in
    let date = Csv.Row.find row "date" |> Date.of_string |> Date.year in
    sprintf "%s: Turns %d years, today!" (Csv.Row.find row "msg") (today-date)

let run csv_file () =
  (* Parse dates and output any date that is the same as today's date.*)
  Reader.file_contents csv_file
  >>| fun csv ->
  csv
  |> read_csv
  |> List.filter ~f:(contains_reminders)
  |> List.iter ~f:(fun r -> Log.Global.info "%s" (prettify r))

let () =
  let spec = Command.Spec.( empty +> anon ("<csv-file-of-events>" %: string)) in
  Command.async_basic ~summary:"Reminders script" spec run
  |> Command.run
