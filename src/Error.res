type commandName = string
type envName = string
type message = string

type t =
  | NotFoundPath(CollectionPath.t)
  | InvalidPath(CollectionPath.t)
  | InvalidDoc(CollectionPath.t)
  | NotFoundCommand(option<commandName>)
  | NotFoundDocument(CollectionPath.t)
  | NoRequiredEnv(envName)
  | InvalidQuery(message)
  | InvalidOption(message)
  | InvalidJson
  | InternalError
  | NotFoundCredential
  | NotFoundCollectionPath

let toString = t => {
  switch t {
  | NotFoundPath(path) => `Not found path: ${path->CollectionPath.toString}.`
  | InvalidPath(path) => `Invalid path: ${path->CollectionPath.toString}.`
  | InvalidDoc(path) => `Invalid doc: ${path->CollectionPath.toString}.`
  | InvalidQuery(message) => `Invalid query: ${message}.`
  | InternalError => "Internal error."
  | InvalidJson => "Input json is bad format."
  | InvalidOption(message) => `Invalid options: ${message}`
  | NotFoundCommand(name) =>
    switch name {
    | Some(n) => `Subcommand: ${n} not found.`
    | None => `Subcommand not found.`
    }
  | NotFoundDocument(path) => `Document ${path->CollectionPath.toString} nof found.`
  | NotFoundCredential => "The json file set to GOOGLE_APPLICATION_CREDENTIALS does not exist."
  | NotFoundCollectionPath => "Collection path is required."
  | NoRequiredEnv(env) =>
    [`env ${env} is required.`, `Run \`export ${env}=value\`.`]->Js.Array2.joinWith("\n")
  }
}
