type t
@module("firebase-admin/firestore") external getFirestore: unit => t = "getFirestore"

module DocSnapshot = {
  type t

  @get external id: t => string = "id"
  @send external data: (t, unit) => 'a = "data"
}

module QuerySnapshot = {
  type t

  @get external docs: t => array<DocSnapshot.t> = "docs"
  @get external size: t => int = "size"
}

module Collection = {
  type t

  module DocRef = {
    type t
    type setOptions = {merge: bool}

    @send external get: (t, unit) => Js.Promise.t<DocSnapshot.t> = "get"
    @send external set: (t, 'a, ~options: setOptions=?, unit) => Js.Promise.t<unit> = "set"
    @send external delete: (t, unit) => Js.Promise.t<unit> = "delete"
  }

  @get external id: t => string = "id"
  @send external get: (t, unit) => Js.Promise.t<QuerySnapshot.t> = "get"
  @send external doc: (t, string) => DocRef.t = "doc"
  @send external offset: (t, int) => t = "offset"
  @send external limit: (t, int) => t = "limit"
  @send external orderBy: (t, string, string) => t = "orderBy"
  @send external startAfter: (t, string) => t = "startAfter"
  @send external startAfter2: (t, string, string) => t = "startAfter"
  @send
  external where: (
    t,
    string,
    @string
    [
      | @as("==") #eq
      | @as("!=") #neq
      | @as(">") #gt
      | @as(">=") #gte
      | @as("<") #lt
      | @as("<=") #lte
      | @as("array-contains") #contains
    ],
    'a,
  ) => t = "where"
}

@send
external listSubCollections: (Collection.DocRef.t, unit) => Js.Promise.t<array<Collection.t>> =
  "listCollections"

@send
external listCollections: (t, unit) => Js.Promise.t<array<Collection.t>> = "listCollections"

@send external collection: (t, string) => Collection.t = "collection"
@send external subCollection: (Collection.DocRef.t, string) => Collection.t = "collection"
