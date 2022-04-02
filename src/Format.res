type t = Json | Table | Csv

let default = Json

let fromString = format =>
  switch format {
  | "json" => Json
  | "table" => Table
  | "csv" => Csv
  | _ => Json
  }

let toString = t =>
  switch t {
  | Json => "json"
  | Table => "table"
  | Csv => "csv"
  }
