open Belt

type dryRun = bool
type rec t =
  | Get(CollectionPath.t, Format.t)
  | Docs(CollectionPath.t, Format.t, Pagination.t)
  | Set(CollectionPath.t, Format.t, Js.Json.t)
  | SetDryRun(CollectionPath.t, Format.t, Js.Json.t)
  | Update(CollectionPath.t, Format.t, Js.Json.t)
  | UpdateDryRun(CollectionPath.t, Format.t, Js.Json.t)
  | List(option<CollectionPath.t>)
  | Delete(CollectionPath.t)
  | DeleteDryRun(CollectionPath.t, Format.t)
  | Code(t)
  | Help(option<t>)
  | Invalid(Error.t)
  | ShowProject
  | Version

let parseOption = (optionString: string) => {
  let tokens = optionString->Js.String2.split("=")->List.fromArray
  switch tokens {
  | list{"--json", json} => list{("json", json)}
  | list{"--stdin"} => list{("stdin", "true")}
  | list{"--limit", limit} => list{("limit", limit)}
  | list{"--offset", offset} => list{("offset", offset)}
  | list{"--start-at", startAt} => list{("start-at", startAt)}
  | list{"--dry-run", dryRun} => list{("dry-run", dryRun)}
  | list{"--format", format} => list{("format", format)}
  | list{"--output-file", outputFile} => list{("output-file", outputFile)}
  | list{"--print-code", code} => list{("print-code", code)}
  | list{"-j", json} => list{("json", json)}
  | list{"-i"} => list{("stdin", "true")}
  | list{"-l", limit} => list{("limit", limit)}
  | list{"-s", offset} => list{("offset", offset)}
  | list{"-d", dryRun} => list{("dry-run", dryRun)}
  | list{"-a", startAt} => list{("start-at", startAt)}
  | list{"-f", format} => list{("format", format)}
  | list{"-o", outputFile} => list{("output-file", outputFile)}
  | _ => list{}
  }
}

let parse = (argv: list<string>): t => {
  let getOptions = rest =>
    rest->List.map(parseOption)->List.toArray->List.concatMany->Js.Dict.fromList
  let getInput = rest => {
    let options = rest->getOptions
    let maybeJsonString = switch (options->Js.Dict.get("json"), options->Js.Dict.get("stdin")) {
    | (Some(json), _) => json->Some
    | (_, Some("true")) => IO.inputStdin()->Some
    | _ => IO.inputStdin()->Some
    }

    switch maybeJsonString {
    | Some("") => Error.InvalidJson->Result.Error
    | Some(jsonString) =>
      try Result.Ok(Js.Json.parseExn(jsonString)) catch {
      | _ => Error.InvalidJson->Result.Error
      }
    | None => Error.InvalidJson->Result.Error
    }
  }

  switch argv {
  | list{"get", "help"} => Get(CollectionPath.empty(), Format.Json)->Some->Help
  | list{"get", "code", path} => Get(path->CollectionPath.fromString, Format.Json)->Code
  | list{"get", path, ...rest} =>
    Get(
      path->CollectionPath.fromString,
      rest
      ->getOptions
      ->Js.Dict.get("format")
      ->Option.map(Format.fromString)
      ->Option.getWithDefault(Format.Json),
    )

  | list{"docs"} => Invalid(Error.NotFoundCollectionPath)
  | list{"docs", "help"} =>
    Docs(CollectionPath.empty(), Format.Json, Pagination.default)->Some->Help
  | list{"docs", "code", path, ...rest} =>
    let options = rest->getOptions
    switch (
      options->Js.Dict.get("limit")->Option.map(Limit.fromString),
      options->Js.Dict.get("offset")->Option.map(Offset.fromString),
      options->Js.Dict.get("start-at")->Option.map(StartAt.fromString),
    ) {
    | (_, Some(_), Some(_)) =>
      Error.InvalidOption("Only one of limit and start-at can be specified as an option")->Invalid
    | (Some(_), _, Some(_)) =>
      Error.InvalidOption("Only one of limit and start-at can be specified as an option")->Invalid
    | _ =>
      Docs(
        path->CollectionPath.fromString,
        Format.Json,
        Pagination.from(
          options->Js.Dict.get("limit")->Option.map(Limit.fromString),
          options->Js.Dict.get("offset")->Option.map(Offset.fromString),
          options->Js.Dict.get("start-at")->Option.map(StartAt.fromString),
        ),
      )->Code
    }
  | list{"docs", path, ...rest} =>
    let options = rest->getOptions
    switch (
      options->Js.Dict.get("limit")->Option.map(Limit.fromString),
      options->Js.Dict.get("offset")->Option.map(Offset.fromString),
      options->Js.Dict.get("start-at")->Option.map(StartAt.fromString),
    ) {
    | (_, Some(_), Some(_)) =>
      Error.InvalidOption("Only one of limit and start-at can be specified as an option")->Invalid
    | (Some(_), _, Some(_)) =>
      Error.InvalidOption("Only one of limit and start-at can be specified as an option")->Invalid
    | _ =>
      Docs(
        path->CollectionPath.fromString,
        options
        ->Js.Dict.get("format")
        ->Option.map(Format.fromString)
        ->Option.getWithDefault(Format.Json),
        Pagination.from(
          options->Js.Dict.get("limit")->Option.map(Limit.fromString),
          options->Js.Dict.get("offset")->Option.map(Offset.fromString),
          options->Js.Dict.get("start-at")->Option.map(StartAt.fromString),
        ),
      )
    }

  | list{"set", "help"} => Set(CollectionPath.empty(), Format.Json, Js.Json.null)->Some->Help
  | list{"set", "code", path, ...rest} =>
    switch rest->getInput {
    | Result.Ok(json) => Set(path->CollectionPath.fromString, Format.Json, json)->Code
    | Result.Error(e) => e->Invalid
    }
  | list{"set", path, ...rest} =>
    let options = rest->getOptions
    switch rest->getInput {
    | Result.Ok(json) =>
      switch options->Js.Dict.get("dry-run")->Option.map(v => v == "true") {
      | Some(true) =>
        SetDryRun(
          path->CollectionPath.fromString,
          options
          ->Js.Dict.get("format")
          ->Option.map(Format.fromString)
          ->Option.getWithDefault(Format.Json),
          json,
        )
      | _ =>
        Set(
          path->CollectionPath.fromString,
          options
          ->Js.Dict.get("format")
          ->Option.map(Format.fromString)
          ->Option.getWithDefault(Format.Json),
          json,
        )
      }

    | Result.Error(e) => e->Invalid
    }

  | list{"update", "help"} => Update(CollectionPath.empty(), Format.Json, Js.Json.null)->Some->Help
  | list{"update", "code", path, ...rest} =>
    switch rest->getInput {
    | Result.Ok(json) => Update(path->CollectionPath.fromString, Format.Json, json)->Code
    | Result.Error(e) => e->Invalid
    }
  | list{"update", path, ...rest} =>
    let options = rest->getOptions
    let maybeJsonString = switch (options->Js.Dict.get("json"), options->Js.Dict.get("stdin")) {
    | (Some(json), _) => json->Some
    | (_, Some("true")) => IO.inputStdin()->Some
    | _ => IO.inputStdin()->Some
    }
    let result = switch maybeJsonString {
    | Some(jsonString) =>
      try Result.Ok(Js.Json.parseExn(jsonString)) catch {
      | _ => Error.InvalidJson->Result.Error
      }
    | None => Error.InvalidJson->Result.Error
    }

    switch result {
    | Result.Ok(json) =>
      switch options->Js.Dict.get("dry-run")->Option.map(v => v == "true") {
      | Some(true) =>
        UpdateDryRun(
          path->CollectionPath.fromString,
          options
          ->Js.Dict.get("format")
          ->Option.map(Format.fromString)
          ->Option.getWithDefault(Format.Json),
          json,
        )
      | _ =>
        Update(
          path->CollectionPath.fromString,
          options
          ->Js.Dict.get("format")
          ->Option.map(Format.fromString)
          ->Option.getWithDefault(Format.Json),
          json,
        )
      }

    | Result.Error(e) => e->Invalid
    }

  | list{"delete", "help"} => CollectionPath.empty()->Delete->Some->Help
  | list{"delete", "code", path} => path->CollectionPath.fromString->Delete->Code
  | list{"delete", path, ...rest} =>
    let options = rest->getOptions
    switch options->Js.Dict.get("dry-run")->Option.map(v => v == "true") {
    | Some(true) =>
      DeleteDryRun(
        path->CollectionPath.fromString,
        options
        ->Js.Dict.get("format")
        ->Option.map(Format.fromString)
        ->Option.getWithDefault(Format.Json),
      )
    | _ => path->CollectionPath.fromString->Delete
    }
  | list{"list", "help"} => None->List->Some->Help
  | list{"list", "code"} => None->List->Code
  | list{"list", "code", path} => path->CollectionPath.fromString->Some->List->Code
  | list{"list", path} => path->CollectionPath.fromString->Some->List
  | list{"list"} => None->List

  | list{"version"} => Version
  | list{"help"} => None->Help
  | list{cmd} => cmd->Some->Error.NotFoundCommand->Invalid
  | list{} => ShowProject
  | _ => None->Error.NotFoundCommand->Invalid
  }
}
