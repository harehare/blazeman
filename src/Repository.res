open Belt
open Firebase
open Firebase.Firestore
open Firebase.Firestore.Collection
open CollectionPath

type t = Firebase.Firestore.t
type cursor = Firestore.DocSnapshot.t

exception RepositoryError(Error.t)

module type Repository = {
  let projectId: unit => string
  let initialize: unit => t
  let docs: (
    t,
    ~path: CollectionPath.t,
    ~pagination: Pagination.t,
  ) => Promise.t<Result.t<array<Js.Dict.t<'a>>, Error.t>>
  let get: (t, ~path: CollectionPath.t) => Promise.t<Result.t<Js.Dict.t<'a>, Error.t>>
  let set: (t, ~path: CollectionPath.t, ~json: Js.Json.t) => Promise.t<Result.t<Js.Json.t, Error.t>>
  let update: (
    t,
    ~path: CollectionPath.t,
    ~json: Js.Json.t,
  ) => Promise.t<Result.t<Js.Json.t, Error.t>>
  let delete: (t, ~path: CollectionPath.t) => Promise.t<Result.t<unit, Error.t>>
  let rootList: t => Promise.t<Result.t<array<string>, Error.t>>
  let subList: (t, ~path: CollectionPath.t) => Promise.t<Result.t<array<string>, Error.t>>
}

type databaseData =
  | DocData(Collection.DocRef.t)
  | CollectionData(Collection.t)

module Repository: Repository = {
  let projectId = () => Firebase.projectId()
  let initialize = () => {
    if Env.credential->NodeJs.Fs.existsSync {
      initializeApp(cert(Env.credential))
      getFirestore()
    } else {
      raise(Error.NotFoundCredential->RepositoryError)
    }
  }

  let getSelection = (path: CollectionPath.t) => {
    switch path->CollectionPath.last {
    | Some(head) =>
      switch head {
      | CollectionPath.SelectionPath(s) => s
      | _ => []
      }
    | None => []
    }
  }

  let selectData = (selection, data) => {
    let fieldNames = selection->Selection.fieldNames
    fieldNames->Array.length > 0
      ? fieldNames
        ->Array.keepMap(s => {
          data
          ->Js.Dict.get(s->Selection.toFieldName)
          ->Option.map(d => (s->Selection.toFieldName, d))
        })
        ->Js.Dict.fromArray
      : data
  }

  let getDatabaseData = (repo, path: CollectionPath.t) => {
    switch path {
    | list{CollectionPath(first), ...rest} =>
      Some(
        rest->List.reduce(CollectionData(repo->collection(first->CollectionName.unwrap)), (
          c,
          v,
        ) => {
          switch (c, v) {
          | (DocData(docData), CollectionPath(collectionName)) =>
            CollectionData(docData->subCollection(collectionName->CollectionName.unwrap))
          | (CollectionData(collectionData), DocPath(docId)) =>
            DocData(collectionData->Collection.doc(docId->DocId.unwrap))
          | (CollectionData(collectionData), QueryPath(queries)) =>
            queries
            ->Array.reduce(collectionData, (c, v) => {
              switch v {
              | Query.EQ(field, value) =>
                switch value {
                | Query.Boolean(b) => c->Collection.where(field, #eq, b)
                | Query.Integer(i) => c->Collection.where(field, #eq, i)
                | Query.String(s) => c->Collection.where(field, #eq, s)
                | Query.Float(f) => c->Collection.where(field, #eq, f)
                }
              | Query.NEQ(field, value) =>
                switch value {
                | Query.Boolean(b) => c->Collection.where(field, #neq, b)
                | Query.Integer(i) => c->Collection.where(field, #neq, i)
                | Query.String(s) => c->Collection.where(field, #neq, s)
                | Query.Float(f) => c->Collection.where(field, #neq, f)
                }
              | Query.GT(field, value) =>
                switch value {
                | Query.Boolean(b) => c->Collection.where(field, #gt, b)
                | Query.Integer(i) => c->Collection.where(field, #gt, i)
                | Query.String(s) => c->Collection.where(field, #gt, s)
                | Query.Float(f) => c->Collection.where(field, #gt, f)
                }
              | Query.GTE(field, value) =>
                switch value {
                | Query.Boolean(b) => c->Collection.where(field, #gte, b)
                | Query.Integer(i) => c->Collection.where(field, #gte, i)
                | Query.String(s) => c->Collection.where(field, #gte, s)
                | Query.Float(f) => c->Collection.where(field, #gte, f)
                }
              | Query.LT(field, value) =>
                switch value {
                | Query.Boolean(b) => c->Collection.where(field, #lt, b)
                | Query.Integer(i) => c->Collection.where(field, #lt, i)
                | Query.String(s) => c->Collection.where(field, #lt, s)
                | Query.Float(f) => c->Collection.where(field, #lt, f)
                }
              | Query.LTE(field, value) =>
                switch value {
                | Query.Boolean(b) => c->Collection.where(field, #lte, b)
                | Query.Integer(i) => c->Collection.where(field, #lte, i)
                | Query.String(s) => c->Collection.where(field, #lte, s)
                | Query.Float(f) => c->Collection.where(field, #lte, f)
                }
              | Query.Contains(field, value) =>
                switch value {
                | Query.Boolean(b) => c->Collection.where(field, #contains, b)
                | Query.Integer(i) => c->Collection.where(field, #contains, i)
                | Query.String(s) => c->Collection.where(field, #contains, s)
                | Query.Float(f) => c->Collection.where(field, #contains, f)
                }
              | Query.InvalidCondition(op) => raise(Error.InvalidQuery(op)->RepositoryError)
              }
            })
            ->CollectionData
          | _ => c
          }
        }),
      )
    | _ => None
    }
  }

  let docs = (repo, ~path, ~pagination) => {
    if path->List.length == 0 {
      Result.Error(path->Error.NotFoundPath)->Promise.resolve
    } else {
      switch repo->getDatabaseData(path) {
      | Some(data) =>
        switch data {
        | CollectionData(collection) =>
          let selection = path->getSelection
          let collection =
            selection
            ->Selection.orders
            ->Array.reduce(collection, (c, v) => {
              switch v {
              | Selection.Asc(Selection.FieldName(name)) => c->Collection.orderBy(name, "asc")
              | Selection.Desc(Selection.FieldName(name)) => c->Collection.orderBy(name, "desc")
              | _ => c
              }
            })
          let collection = try switch pagination {
          | Pagination.Pagination(offset, limit) =>
            collection
            ->Collection.offset(offset->Offset.unwrap)
            ->Collection.limit(limit->Limit.unwrap)
          | Cursor(startAt) =>
            switch startAt->StartAt.toArray {
            | [field1, field2] => collection->Collection.startAfter2(field1, field2)
            | [field1] => collection->Collection.startAfter(field1)
            | _ => collection
            }
          } catch {
          | Js.Exn.Error(obj) =>
            switch Js.Exn.message(obj) {
            | Some(m) => raise(Error.InvalidOption(m)->RepositoryError)
            | None => raise(Error.InternalError->RepositoryError)
            }
          }
          collection
          ->Collection.get()
          ->Promise.then(qs =>
            Result.Ok(
              qs
              ->QuerySnapshot.docs
              ->Array.map(doc => {
                let docData = doc->DocSnapshot.data()
                docData->Js.Dict.set("id", doc->DocSnapshot.id)
                selection->selectData(docData)
              }),
            )->Promise.resolve
          )
          ->Promise.catch(e => {
            switch e {
            | Promise.JsError(obj) =>
              switch Js.Exn.message(obj) {
              | Some(msg) =>
                Js.Console.log(msg)
                if (
                  msg->Js.String2.endsWith(
                    "Only a single array-contains clause is allowed in a query",
                  )
                ) {
                  "Only a single contains clause is allowed in a query"->Error.InvalidQuery
                } else {
                  Error.InternalError
                }
              | _ => Error.InternalError
              }
            | _ => Error.InternalError
            }
            ->Result.Error
            ->Promise.resolve
          })

        | _ => Result.Error(path->Error.InvalidPath)->Promise.resolve
        }
      | None => Result.Error(path->Error.NotFoundPath)->Promise.resolve
      }
    }
  }

  let get = (repo, ~path) => {
    if path->List.length == 0 {
      Result.Error(path->Error.NotFoundPath)->Promise.resolve
    } else {
      switch repo->getDatabaseData(path) {
      | Some(data) =>
        switch data {
        | DocData(doc) =>
          doc
          ->DocRef.get()
          ->Promise.then(ds => {
            let selection = path->getSelection
            let docData = ds->DocSnapshot.data()
            switch docData {
            | Some(data) => Result.Ok(selection->selectData(data))->Promise.resolve
            | None => Result.Error(path->Error.NotFoundDocument)->Promise.resolve
            }
          })
          ->Promise.catch(_ => {
            Result.Error(Error.InternalError)->Promise.resolve
          })

        | _ => Result.Error(path->Error.InvalidPath)->Promise.resolve
        }
      | None => Result.Error(path->Error.NotFoundPath)->Promise.resolve
      }
    }
  }

  let set = (repo, ~path, ~json) => {
    if path->List.length == 0 {
      Result.Error(path->Error.NotFoundPath)->Promise.resolve
    } else {
      switch repo->getDatabaseData(path) {
      | Some(data) =>
        switch data {
        | DocData(doc) =>
          doc
          ->DocRef.set(json, ())
          ->Promise.then(() => Result.Ok(json)->Promise.resolve)
          ->Promise.catch(_ => Result.Error(Error.InternalError)->Promise.resolve)

        | _ => path->Error.InvalidPath->Result.Error->Promise.resolve
        }
      | None => path->Error.NotFoundPath->Result.Error->Promise.resolve
      }
    }
  }

  let update = (repo, ~path, ~json) => {
    if path->List.length == 0 {
      Result.Error(path->Error.NotFoundPath)->Promise.resolve
    } else {
      switch repo->getDatabaseData(path) {
      | Some(data) =>
        switch data {
        | DocData(doc) =>
          doc
          ->DocRef.set(json, ~options={merge: true}, ())
          ->Promise.then(() => Result.Ok(json)->Promise.resolve)
          ->Promise.catch(_ => Result.Error(Error.InternalError)->Promise.resolve)

        | _ => path->Error.InvalidPath->Result.Error->Promise.resolve
        }
      | None => path->Error.NotFoundPath->Result.Error->Promise.resolve
      }
    }
  }

  let delete = (repo, ~path) => {
    if path->List.length == 0 {
      Result.Error(path->Error.NotFoundPath)->Promise.resolve
    } else {
      switch repo->getDatabaseData(path) {
      | Some(data) =>
        switch data {
        | DocData(doc) =>
          doc
          ->DocRef.delete()
          ->Promise.then(() => ()->Result.Ok->Promise.resolve)
          ->Promise.catch(_ => Error.InternalError->Result.Error->Promise.resolve)

        | _ => path->Error.InvalidPath->Result.Error->Promise.resolve
        }
      | None => path->Error.NotFoundPath->Result.Error->Promise.resolve
      }
    }
  }

  let rootList = repo => {
    repo
    ->Firestore.listCollections()
    ->Promise.then(collections =>
      collections->Array.map(collection => collection->Collection.id)->Result.Ok->Promise.resolve
    )
    ->Promise.catch(_ => Error.InternalError->Result.Error->Promise.resolve)
  }

  let subList = (repo, ~path) => {
    switch path {
    | list{CollectionPath(first), ...restPath} =>
      let data = restPath->List.reduce(
        CollectionData(repo->collection(first->CollectionName.unwrap)),
        (c, v) => {
          switch (c, v) {
          | (DocData(docData), CollectionPath(collectionName)) =>
            CollectionData(docData->subCollection(collectionName->CollectionName.unwrap))
          | (CollectionData(collectionData), DocPath(docId)) =>
            DocData(collectionData->Collection.doc(docId->DocId.unwrap))

          | _ => c
          }
        },
      )

      switch data {
      | DocData(doc) =>
        doc
        ->listSubCollections()
        ->Promise.then(collections =>
          collections
          ->Array.map(collection => collection->Collection.id)
          ->Result.Ok
          ->Promise.resolve
        )
        ->Promise.catch(_ => Error.InternalError->Result.Error->Promise.resolve)

      | _ => path->Error.InvalidPath->Result.Error->Promise.resolve
      }
    | _ => path->Error.InvalidPath->Result.Error->Promise.resolve
    }
  }
}
