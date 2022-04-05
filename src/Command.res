open Belt

type dryRun = bool
type rec t =
  | Get(CollectionPath.t, Format.t)
  | Docs(CollectionPath.t, Format.t, option<Limit.t>, option<Offset.t>)
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
  | list{"--dry-run", dryRun} => list{("dry-run", dryRun)}
  | list{"--format", format} => list{("format", format)}
  | list{"--output-file", outputFile} => list{("output-file", outputFile)}
  | list{"--print-code", code} => list{("print-code", code)}
  | list{"-j", json} => list{("json", json)}
  | list{"-i"} => list{("stdin", "true")}
  | list{"-l", limit} => list{("limit", limit)}
  | list{"-s", offset} => list{("offset", offset)}
  | list{"-d", dryRun} => list{("dry-run", dryRun)}
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
    | (Some(json), _) => Some(json)
    | (_, Some("true")) => Some(IO.inputStdin())
    | _ => Some(IO.inputStdin())
    }

    switch maybeJsonString {
    | Some("") => Result.Error(Error.InvalidJson)
    | Some(jsonString) =>
      try Result.Ok(Js.Json.parseExn(jsonString)) catch {
      | _ => Result.Error(Error.InvalidJson)
      }
    | None => Result.Error(Error.InvalidJson)
    }
  }

  switch argv {
  | list{"get", "help"} => Help(Some(Get(CollectionPath.empty(), Format.Json)))
  | list{"get", "code", path} => Code(Get(path->CollectionPath.fromString, Format.Json))
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
  | list{"docs", "help"} => Help(Some(Docs(CollectionPath.empty(), Format.Json, None, None)))
  | list{"docs", "code", path, ...rest} =>
    let options = rest->getOptions
    Code(
      Docs(
        path->CollectionPath.fromString,
        Format.Json,
        options->Js.Dict.get("limit")->Option.map(Limit.fromString),
        options->Js.Dict.get("offset")->Option.map(Offset.fromString),
      ),
    )
  | list{"docs", path, ...rest} =>
    let options = rest->getOptions
    Docs(
      path->CollectionPath.fromString,
      options
      ->Js.Dict.get("format")
      ->Option.map(Format.fromString)
      ->Option.getWithDefault(Format.Json),
      options->Js.Dict.get("limit")->Option.map(Limit.fromString),
      options->Js.Dict.get("offset")->Option.map(Offset.fromString),
    )

  | list{"set", "help"} => Help(Some(Set(CollectionPath.empty(), Format.Json, Js.Json.null)))
  | list{"set", "code", path, ...rest} =>
    switch rest->getInput {
    | Result.Ok(json) => Code(Set(path->CollectionPath.fromString, Format.Json, json))
    | Result.Error(e) => Invalid(e)
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

    | Result.Error(e) => Invalid(e)
    }

  | list{"update", "help"} => Help(Some(Update(CollectionPath.empty(), Format.Json, Js.Json.null)))
  | list{"update", "code", path, ...rest} =>
    switch rest->getInput {
    | Result.Ok(json) => Code(Update(path->CollectionPath.fromString, Format.Json, json))
    | Result.Error(e) => Invalid(e)
    }
  | list{"update", path, ...rest} =>
    let options = rest->getOptions
    let maybeJsonString = switch (options->Js.Dict.get("json"), options->Js.Dict.get("stdin")) {
    | (Some(json), _) => Some(json)
    | (_, Some("true")) => Some(IO.inputStdin())
    | _ => Some(IO.inputStdin())
    }
    let result = switch maybeJsonString {
    | Some(jsonString) =>
      try Result.Ok(Js.Json.parseExn(jsonString)) catch {
      | _ => Result.Error(Error.InvalidJson)
      }
    | None => Result.Error(Error.InvalidJson)
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

    | Result.Error(e) => Invalid(e)
    }

  | list{"delete", "help"} => Help(Some(Delete(CollectionPath.empty())))
  | list{"delete", "code", path} => Code(Delete(path->CollectionPath.fromString))
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
    | _ => Delete(path->CollectionPath.fromString)
    }
  | list{"list", "help"} => Help(Some(List(None)))
  | list{"list", "code"} => Code(List(None))
  | list{"list", "code", path} => Code(List(Some(path->CollectionPath.fromString)))
  | list{"list", path} => List(Some(path->CollectionPath.fromString))
  | list{"list"} => List(None)

  | list{"version"} => Version
  | list{"help"} => Help(None)
  | list{cmd} => Invalid(Error.NotFoundCommand(Some(cmd)))
  | list{} => ShowProject
  | _ => Invalid(Error.NotFoundCommand(None))
  }
}
