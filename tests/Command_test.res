open Test

test("parse get", () => {
  Assert.commandEqual(
    Command.parse(list{"get", "/collection1/docId1/collection2/docId2"}),
    Command.Get("/collection1/docId1/collection2/docId2"->CollectionPath.fromString, Format.Json),
  )
})

test("parse docs", () => {
  Assert.commandEqual(
    Command.parse(list{
      "docs",
      "/collection1/docId1/collection2/docId2",
      "--limit=10",
      "--offset=20",
      "--format=json",
    }),
    Command.Docs(
      "/collection1/docId1/collection2/docId2"->CollectionPath.fromString,
      Format.fromString("json"),
      Pagination.from(Some(Limit.fromString("10")), Some(Offset.fromString("20")), None),
    ),
  )

  Assert.commandEqual(
    Command.parse(list{"docs", "/collection1/docId1/collection2"}),
    Command.Docs(
      "/collection1/docId1/collection2"->CollectionPath.fromString,
      Format.Json,
      Pagination.default,
    ),
  )
})

test("parse set", () => {
  let inputJson = try Js.Json.parseExn(`{"test": 1}`) catch {
  | _ => failwith("Error parsing JSON string")
  }

  Assert.commandEqual(
    Command.parse(list{
      "set",
      "/collection1/docId1/collection2/docId2",
      `--json={"test": 1}`,
      "--dry-run=true",
    }),
    Command.SetDryRun(
      "/collection1/docId1/collection2/docId2"->CollectionPath.fromString,
      Format.Json,
      inputJson,
    ),
  )

  Assert.commandEqual(
    Command.parse(list{
      "set",
      "/collection1/docId1/collection2/docId2",
      `--json={"test": 1}`,
      "--dry-run=false",
    }),
    Command.Set(
      "/collection1/docId1/collection2/docId2"->CollectionPath.fromString,
      Format.Json,
      inputJson,
    ),
  )
})

test("parse update", () => {
  let inputJson = try Js.Json.parseExn(`{"test": 1}`) catch {
  | _ => failwith("Error parsing JSON string")
  }

  Assert.commandEqual(
    Command.parse(list{
      "update",
      "/collection1/docId1/collection2/docId2",
      `--json={"test": 1}`,
      "--dry-run=true",
    }),
    Command.UpdateDryRun(
      "/collection1/docId1/collection2/docId2"->CollectionPath.fromString,
      Format.Json,
      inputJson,
    ),
  )

  Assert.commandEqual(
    Command.parse(list{
      "update",
      "/collection1/docId1/collection2/docId2",
      `--json={"test": 1}`,
      "--dry-run=false",
    }),
    Command.Update(
      "/collection1/docId1/collection2/docId2"->CollectionPath.fromString,
      Format.Json,
      inputJson,
    ),
  )
})

test("parse list", () => {
  Assert.commandEqual(Command.parse(list{"list"}), Command.List(None))
  Assert.commandEqual(
    Command.parse(list{"list", "/collection1/docId1"}),
    Command.List(Some("/collection1/docId1"->CollectionPath.fromString)),
  )
})

test("parse delete", () => {
  Assert.commandEqual(
    Command.parse(list{"delete", "/collection1/docId1", "--dry-run=true"}),
    Command.DeleteDryRun("/collection1/docId1"->CollectionPath.fromString, Format.Json),
  )

  Assert.commandEqual(
    Command.parse(list{"delete", "/collection1/docId1", "--dry-run=false"}),
    Command.Delete("/collection1/docId1"->CollectionPath.fromString),
  )
})

test("parse help", () => {
  Assert.commandEqual(Command.parse(list{"help"}), Command.Help(None))
})

test("parse invalid", () => {
  Assert.commandEqual(Command.parse(list{"invalid"}), Command.Invalid(Error.InternalError))
})

test("parse version", () => {
  Assert.commandEqual(Command.parse(list{"version"}), Command.Version)
})
