let usage = [
  "Usage:"->IO.green,
  "    bm  Show current project id",
  "    bm <Subcommands> [Options]",
  "",
  "Subcommands:"->IO.green,
  "    get    Retrieve an doc by specifying collection path.",
  "    docs   Retrieve docs in a collection.",
  "    set    Create a new doc, or replace an existing doc.",
  "    update Update an existing doc.",
  "    delete Delete an existing collection or doc.",
  "    help   Prints this message",
]

let help =
  ["bm is a command line tool to Firebase firestore."]
  ->Js.Array2.concat(usage)
  ->Js.Array2.joinWith("\n")

let get =
  [
    "Get document from Firestore collection.",
    "",
    "Usage:"->IO.green,
    "    bm get \"[Collectiotn path]\" [Options]",
    "    bm get code \"[Collectiotn path]\"",
    "Options:"->IO.green,
    "    -f, --format=<json|table|csv>",
  ]->Js.Array2.joinWith("\n")

let docs =
  [
    "Get documents from Firestore collection.",
    "",
    "Usage:"->IO.green,
    "    bm docs \"[Collectiotn path]\" [Options]",
    "    bm docs \"[Collectiotn path]/[Queries]\" [Options]",
    "    bm docs \"[Collectiotn path]/[Queries]/[Fields|Order by]\" [Options]",
    "    bm docs code \"[Collectiotn path]/[Queries]/[Fields|Order by]\" [Options]",
    "",
    "Collectiotn path:"->IO.green,
    "    /collection",
    "    /collection/docid/subcollection",
    "Queries:"->IO.green,
    "    /[field == 'string value']",
    "    /[field == int value]/",
    "    /[field == true]/",
    "    /[field == false]/",
    "    /[field != value]/",
    "    /[field >= value]/",
    "    /[field > value]/",
    "    /[field < value]/",
    "    /[field <= value]/",
    "    /[map.value == value]/",
    "    /[array contains value]/",
    "Fields:"->IO.green,
    "    /{field1, field2}",
    "Order by:"->IO.green,
    "    /{^field1, _field2}",
    "Options:"->IO.green,
    "    -l, --limit=<limit> defaults to 30",
    "    -s, --offset=<offset> defaults to 0",
    "    -f, --format=<json|table|csv>",
  ]->Js.Array2.joinWith("\n")

let set =
  [
    "Replace document into Firestore document.",
    "",
    "Usage:"->IO.green,
    "    bm set [Collectiotn path] [Options]",
    "    bm set code [Collectiotn path] [Options]",
    "",
    "Options:"->IO.green,
    "    -d, --dry-run=<true|false> Skip operations.",
    "    -i, --stdin",
    "    -j, --json=<input json>",
    "    -f, --format=<json|table|csv>",
  ]->Js.Array2.joinWith("\n")

let update =
  [
    "Update document into Firestore document.",
    "",
    "Usage:"->IO.green,
    "    bm update [Collectiotn path] [Options]",
    "    bm update code [Collectiotn path] [Options]",
    "",
    "Options:"->IO.green,
    "    -d, --dry-run=<true|false> Skip operations.",
    "    -i, --stdin",
    "    -j, --json=<input json>",
    "    -f, --format=<json|table|csv>",
  ]->Js.Array2.joinWith("\n")

let list =
  [
    "List collection.",
    "",
    "Usage:"->IO.green,
    "    bm list [Collectiotn path]",
    "    bm list code [Collectiotn path]",
  ]->Js.Array2.joinWith("\n")

let delete =
  [
    "Delete a firestore document.",
    "",
    "Usage:"->IO.green,
    "    bm delete [Collectiotn path] [Options]",
    "    bm delete code [Collectiotn path] [Options]",
    "",
    "Options:"->IO.green,
    "    -d, --dry-run=<true|false> Skip operations.",
    "    -f, --format=<json|table|csv>",
  ]->Js.Array2.joinWith("\n")
