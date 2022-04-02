@module external colorizer: string => string = "json-colorizer"
@module("console-table-printer") external printTable: 'a => unit = "printTable"
@module("json2csv") external json2csv: 'a => string = "parse"
@module("fs") external readFileSync: int => NodeJs.Buffer.t = "readFileSync"

let red = text => `\x1b[31m${text}\x1b[0m`
let green = text => `\x1b[32m${text}\x1b[0m`
let yellow = text => `\x1b[33m${text}\x1b[0m`
let blue = text => `\x1b[34m${text}\x1b[0m`
let cyan = text => `\x1b[36m${text}\x1b[0m`
let bold = text => `\x1b[1m${text}\x1b[0m`

let successfulMessage = text => text->green->bold->Js.Console.error
let noticeMessage = text => text->cyan->bold->Js.Console.error
let warningMessage = text => text->yellow->bold->Js.Console.error
let errorMessage = text => text->red->bold->Js.Console.error

let info = text => text->Js.Console.log
let newLine = () => ""->Js.Console.log

let error = err => err->Error.toString->errorMessage
let errorFromString = err => err->errorMessage

let inputStdin = () =>
  try readFileSync(0)->NodeJs.Buffer.toStringWithEncoding(NodeJs.StringEncoding.utf8) catch {
  | _ => ""
  }

let json = values => Js.Json.stringifyWithSpace(values, 2)->colorizer->Js.Console.log
let table = values => values->printTable
let csv = values => values->json2csv->info
