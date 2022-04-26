blazeman - Cloud Firestore CLI
<img src=".github/icon.svg" alt="logo" title="logo" width="32">
========================================

blazeman is a command line interface for Cloud Firestore written in Rescript. blazeman that makes query and update easy.

# Installation

To install run

```
$ npm install -g blazeman
```

## How to Use

## Prerequisites

Set the environment variable GOOGLE_APPLICATION_CREDENTIALS to the file path of the json file containing the service account key.

## Commands overview

`bm`, show current project name.

```sh
$ bm
Active Project: XXXXXXXX
```

`bm list`, which lists collections.

```sh
$ bm list
[
  "collection1",
  "collection2",
]
```

`bm docs`, retrieve docs in the collection.

```sh
$ bm docs "/collection1/[enabled == true]/{id, name, description, enabled}"
[
  {
      id: "test",
      name: "name",
      description: "description",
      enabled: true
  }
]
```

`bm set`, to add or set an document.

```sh
$ bm set "/collection1/docId1" --json='{"field1": 1, "field2": "2"}' --dry-run=false
{
  "field1": 1
  "field2": "2"
}
$ echo '{"field1": 1, "field2": "2"}' | bm set "/collection1/docId1" --dry-run=false
{
  "field1": 1
  "field2": "2"
}
```

`bm update`, to update an document.

```sh
$ bm update "/collection1/docId1" --json='{"field1": 10}' --dry-run=false
{
  "field1": 10
  "field2": "2"
}
$ echo '{"field1": 10}' | bm update "/collection1/docId1" --dry-run=false
{
  "field1": 10
  "field2": "2"
}
```

To find more features, `bm help` or `bm [Subcommands] help` will show you complete list of available commands.

```sh
$ bm help
bm is a command line tool to Firebase firestore.
Usage:
    bm  Show current project id
    bm <Subcommands> [Options]

Subcommands:
    get    Retrieve an doc by specifying collection path.
    docs   Retrieve docs in a collection.
    set    Create a new doc, or replace an existing doc.
    update Update an existing doc.
    delete Delete an existing collection or doc.
    help   Prints this message
$ bm docs help
Get documents from Firestore collection.

Usage:
    bm docs "[Collectiotn path]" [Options]
    bm docs "[Collectiotn path]/[Queries]" [Options]
    bm docs "[Collectiotn path]/[Queries]/[Fields|Order by]" [Options]
    bm docs code "[Collectiotn path]/[Queries]/[Fields|Order by]" [Options]

Collectiotn path:
    /collection
    /collection/docid/subcollection
Queries:
    /[field == 'string value']
    /[field == int value]/
    /[field == true]/
    /[field == false]/
    /[field != value]/
    /[field >= value]/
    /[field > value]/
    /[field < value]/
    /[field <= value]/
    /[map.value == value]/
    /[array contains value]/
Fields:
    /{field1, field2}
Order by:
    /{^field1, _field2}
Options:
    -l, --limit=<limit> defaults to 30
    -s, --offset=<offset> defaults to 0
    -a, --start-at=<startAt>
    -f, --format=<json|table|csv>
```

## License

[MIT](http://opensource.org/licenses/MIT)
