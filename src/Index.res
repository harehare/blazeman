open NodeJs
open Belt
open Repository

let executeGet = (repo, ~path, ~format) =>
  repo
  ->Repository.get(~path)
  ->Promise.then(result => {
    switch result {
    | Result.Ok(ok) =>
      switch format {
      | Format.Table => [ok]->IO.table
      | Format.Json => Jzon.json->Jzon.dict->Jzon.encode(ok)->IO.json
      | Format.Csv => ok->IO.csv
      }
    | Result.Error(e) => e->IO.error
    }
    Process.process->Process.exitWithCode(0)
    Promise.resolve()
  })
  ->ignore

let executeDocs = (repo, ~path: CollectionPath.t, ~limit, ~offset, ~format) =>
  repo
  ->Repository.docs(~path, ~offset=offset->Offset.unwrap, ~limit=limit->Limit.unwrap)
  ->Promise.then(result => {
    switch result {
    | Result.Ok(ok) =>
      switch format {
      | Format.Table => ok->IO.table
      | Format.Json => Jzon.json->Jzon.dict->Jzon.array->Jzon.encode(ok)->IO.json
      | Format.Csv => ok->IO.csv
      }
    | Result.Error(e) => e->IO.error
    }
    Process.process->Process.exitWithCode(0)
    Promise.resolve()
  })
  ->ignore

let executeSet = (repo, ~path: CollectionPath.t, ~json: Js.Json.t, ~format) =>
  repo
  ->Repository.set(~path, ~json)
  ->Promise.then(result => {
    switch result {
    | Result.Ok(ok) =>
      switch format {
      | Format.Table => [ok]->IO.table
      | Format.Json => ok->IO.json
      | Format.Csv => ok->IO.csv
      }
    | Result.Error(e) => e->IO.error
    }
    Process.process->Process.exitWithCode(0)
    Promise.resolve()
  })
  ->ignore

let executeSetDryRun = (repo, ~path: CollectionPath.t, ~json: Js.Json.t, ~format) =>
  repo
  ->Repository.get(~path)
  ->Promise.then(result => {
    switch result {
    | Result.Ok(ok) =>
      "Get current document:"->IO.noticeMessage
      Js.Dict.unsafeDeleteKey(. ok, "id")
      switch format {
      | Format.Table => [ok]->IO.table
      | Format.Json => Jzon.string->Jzon.dict->Jzon.encode(ok)->IO.json
      | Format.Csv => ok->IO.csv
      }
      IO.newLine()

      "Updated document:"->IO.noticeMessage
      switch format {
      | Format.Table => [json]->IO.table
      | Format.Json => json->IO.json
      | Format.Csv => json->IO.csv
      }
      Message.dryRun->IO.warningMessage
    | Result.Error(Error.NotFoundDocument(_)) =>
      "Created document"->IO.noticeMessage
      switch format {
      | Format.Table => [json]->IO.table
      | Format.Json => json->IO.json
      | Format.Csv => json->IO.csv
      }
      Message.dryRun->IO.warningMessage

    | Result.Error(e) => e->IO.error
    }
    Process.process->Process.exitWithCode(0)
    Promise.resolve()
  })
  ->ignore

let executeUpdate = (repo, ~path: CollectionPath.t, ~json: Js.Json.t, ~format) =>
  repo
  ->Repository.update(~path, ~json)
  ->Promise.then(result => {
    switch result {
    | Result.Ok(_) =>
      repo
      ->Repository.get(~path)
      ->Promise.then(result => {
        switch result {
        | Result.Ok(getResult) =>
          switch format {
          | Format.Table => [getResult]->IO.table
          | Format.Json => Jzon.string->Jzon.dict->Jzon.encode(getResult)->IO.json
          | Format.Csv => getResult->IO.csv
          }
        | Result.Error(e) => e->IO.error
        }
        Process.process->Process.exitWithCode(0)
        Promise.resolve()
      })
      ->ignore
    | Result.Error(e) =>
      e->IO.error
      Process.process->Process.exitWithCode(0)
    }
    Promise.resolve()
  })
  ->ignore

let executeUpdateDryRun = (repo, ~path: CollectionPath.t, ~json: Js.Json.t, ~format) => {
  let decodedJson = json->Jzon.asObject

  Repository.get(repo, ~path)
  ->Promise.then(result => {
    switch (result, decodedJson) {
    | (Result.Ok(currentJson), Result.Ok(updateJson)) =>
      let newData =
        Array.concat(currentJson->Js.Dict.entries, updateJson->Js.Dict.entries)->Js.Dict.fromArray

      "Get current document:"->IO.noticeMessage
      switch format {
      | Format.Table => [currentJson]->IO.table
      | Format.Json => Jzon.json->Jzon.dict->Jzon.encode(currentJson)->IO.json
      | Format.Csv => currentJson->IO.csv
      }
      IO.newLine()

      "Updated document:"->IO.noticeMessage
      switch format {
      | Format.Table => [newData]->IO.table
      | Format.Json => Jzon.json->Jzon.dict->Jzon.encode(newData)->IO.json
      | Format.Csv => newData->IO.csv
      }
      Message.dryRun->IO.warningMessage
      Process.process->Process.exitWithCode(0)
    | (Result.Error(e), _) => e->IO.error
    | (_, Result.Error(e)) => e->Jzon.DecodingError.toString->IO.errorFromString
    }
    Process.process->Process.exitWithCode(0)
    Promise.resolve()
  })
  ->ignore
}

let executeList = (repo, path) =>
  switch path {
  | Some(p) =>
    repo
    ->Repository.subList(~path=p)
    ->Promise.then(result => {
      switch result {
      | Result.Ok(ok) => Jzon.string->Jzon.array->Jzon.encode(ok)->IO.json
      | Result.Error(e) => e->IO.error
      }
      Process.process->Process.exitWithCode(0)
      Promise.resolve()
    })
    ->ignore
  | None =>
    repo
    ->Repository.rootList
    ->Promise.then(result => {
      switch result {
      | Result.Ok(ok) => Jzon.string->Jzon.array->Jzon.encode(ok)->IO.json
      | Result.Error(e) => e->IO.error
      }
      Process.process->Process.exitWithCode(0)
      Promise.resolve()
    })
    ->ignore
  }

let executeDelete = (repo, ~path) =>
  repo
  ->Repository.delete(~path)
  ->Promise.then(result => {
    switch result {
    | Result.Error(e) => e->IO.error
    | _ => ()
    }
    Process.process->Process.exitWithCode(0)
    Promise.resolve()
  })
  ->ignore

let executeDeleteDryRun = (repo, ~path, ~format) =>
  repo
  ->Repository.get(~path)
  ->Promise.then(result => {
    switch result {
    | Result.Ok(currentJson) =>
      "delete:"->IO.warningMessage
      switch format {
      | Format.Table => [currentJson]->IO.table
      | Format.Json => Jzon.json->Jzon.dict->Jzon.encode(currentJson)->IO.json
      | Format.Csv => currentJson->IO.csv
      }

      IO.newLine()
      Message.dryRun->IO.warningMessage
      Process.process->Process.exitWithCode(0)
    | Result.Error(e) =>
      e->IO.error
      Process.process->Process.exitWithCode(0)
    }
    Promise.resolve()
  })
  ->ignore

let main = () => {
  let repo = Repository.initialize()
  let isDevelopment =
    Process.process
    ->Process.env
    ->Js.Dict.get("NODE_ENV")
    ->Option.getWithDefault("production") == "development"
  let commands =
    Process.process
    ->Process.argv
    ->List.fromArray
    ->List.drop(isDevelopment ? 2 : 1)
    ->Option.getWithDefault(list{})

  switch commands->Command.parse {
  | Get(path, format) => repo->executeGet(~path, ~format)
  | Docs(path, format, limit, offset) =>
    repo->executeDocs(
      ~path,
      ~format,
      ~limit=limit->Option.getWithDefault(Limit.default),
      ~offset=offset->Option.getWithDefault(Offset.default),
    )
  | Set(path, format, json) => repo->executeSet(~path, ~json, ~format)
  | SetDryRun(path, format, json) => repo->executeSetDryRun(~path, ~json, ~format)
  | Update(path, format, json) => repo->executeUpdate(~path, ~json, ~format)
  | UpdateDryRun(path, format, json) => repo->executeUpdateDryRun(~path, ~json, ~format)
  | List(path) => repo->executeList(path)
  | Delete(path) => repo->executeDelete(~path)
  | DeleteDryRun(path, format) => repo->executeDeleteDryRun(~path, ~format)
  | Help(Some(Get(_))) => Help.get->IO.info
  | Help(Some(Set(_))) => Help.set->IO.info
  | Help(Some(Docs(_))) => Help.docs->IO.info
  | Help(Some(Update(_))) => Help.update->IO.info
  | Help(Some(List(_))) => Help.list->IO.info
  | Help(Some(Delete(_))) => Help.delete->IO.info
  | Help(_) => Help.help->IO.info
  | Invalid(e) => e->IO.error
  | ShowProject => `Active Project: ${Repository.projectId()->IO.cyan->IO.bold}`->IO.info
  | Version => "0.1.1"->IO.info
  }->ignore
}

switch Env.hasRequiredEnv() {
| Result.Ok() =>
  try main() catch {
  | RepositoryError(e) => e->IO.error
  }
| Result.Error(e) => e->IO.error
}->ignore
