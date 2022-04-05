open Belt

type path =
  | CollectionPath(CollectionName.t)
  | DocPath(DocId.t)
  | QueryPath(array<Query.t>)
  | SelectionPath(Selection.t)

type t = list<path>

let empty = (): t => list{}
let last = t => t->List.reverse->List.head

let fromString = pathString => {
  let rec createCollectionPath = (t, tokens) => {
    switch tokens {
    | list{collectionName, ...rest} =>
      let query = Query.fromQueryString(collectionName)
      let selection = Selection.fromString(collectionName)

      switch (query, selection) {
      | (Some(q), None) => list{QueryPath(q), ...createDocPath(t, rest)}
      | (None, Some(s)) => list{SelectionPath(s), ...createDocPath(t, rest)}
      | _ => list{
          CollectionPath(collectionName->CollectionName.fromString),
          ...createDocPath(t, rest),
        }
      }
    | _ => t
    }
  }
  and createDocPath = (t, tokens) => {
    switch tokens {
    | list{docId, ...rest} =>
      let query = Query.fromQueryString(docId)
      let selection = Selection.fromString(docId)

      switch (query, selection) {
      | (Some(q), None) => list{QueryPath(q), ...createCollectionPath(t, rest)}
      | (None, Some(s)) => list{SelectionPath(s), ...createCollectionPath(t, rest)}
      | _ => list{DocPath(docId->DocId.fromString), ...createCollectionPath(t, rest)}
      }
    | _ => t
    }
  }

  empty()->createCollectionPath(
    pathString->Js.String2.split("/")->Array.keep(v => v !== "")->List.fromArray,
  )
}

let toString = t => {
  t->List.reduce("", (acc, path) =>
    switch path {
    | CollectionPath(collectionName) => `${acc}/${collectionName->CollectionName.unwrap}`
    | DocPath(docId) => `${acc}/${docId->DocId.unwrap}`
    | QueryPath(_) => acc
    | SelectionPath(_) => acc
    }
  )
}

let toCode = t => {
  t
  ->List.reduce(["db"], (acc, path) =>
    switch path {
    | CollectionPath(collectionName) =>
      acc->Array.concat([`collection('${collectionName->CollectionName.unwrap}')`])
    | DocPath(docId) => acc->Array.concat([`doc('${docId->DocId.unwrap}')`])
    | QueryPath(queries) =>
      acc->Array.concat(
        queries->Array.reduce([], (acc, v) => {
          switch v {
          | Query.EQ(field, value) =>
            switch value {
            | Query.Boolean(b) =>
              acc->Array.concat([`where('${field}', '==', ${b ? "true" : "false"}})`])
            | Query.Integer(i) =>
              acc->Array.concat([`where('${field}', '==', ${i->Int.toString}})`])
            | Query.String(s) => acc->Array.concat([`where('${field}', '==', '${s}'})`])
            | Query.Float(f) =>
              acc->Array.concat([`where('${field}', '==', ${f->Float.toString}})`])
            }
          | Query.NEQ(field, value) =>
            switch value {
            | Query.Boolean(b) =>
              acc->Array.concat([`where('${field}', '!=', ${b ? "true" : "false"}})`])
            | Query.Integer(i) =>
              acc->Array.concat([`where('${field}', '!=', ${i->Int.toString}})`])
            | Query.String(s) => acc->Array.concat([`where('${field}', '!=', '${s}'})`])
            | Query.Float(f) =>
              acc->Array.concat([`where('${field}', '!=', ${f->Float.toString}})`])
            }
          | Query.GT(field, value) =>
            switch value {
            | Query.Boolean(b) =>
              acc->Array.concat([`where('${field}', '>', ${b ? "true" : "false"}})`])
            | Query.Integer(i) => acc->Array.concat([`where('${field}', '>', ${i->Int.toString}})`])
            | Query.String(s) => acc->Array.concat([`where('${field}', '>', '${s}'})`])
            | Query.Float(f) => acc->Array.concat([`where('${field}', '>', ${f->Float.toString}})`])
            }
          | Query.GTE(field, value) =>
            switch value {
            | Query.Boolean(b) =>
              acc->Array.concat([`where('${field}', '>=', ${b ? "true" : "false"}})`])
            | Query.Integer(i) =>
              acc->Array.concat([`where('${field}', '>=', ${i->Int.toString}})`])
            | Query.String(s) => acc->Array.concat([`where('${field}', '>=', '${s}'})`])
            | Query.Float(f) =>
              acc->Array.concat([`where('${field}', '>=', ${f->Float.toString}})`])
            }
          | Query.LT(field, value) =>
            switch value {
            | Query.Boolean(b) =>
              acc->Array.concat([`where('${field}', '<', ${b ? "true" : "false"}})`])
            | Query.Integer(i) => acc->Array.concat([`where('${field}', '<', ${i->Int.toString}})`])
            | Query.String(s) => acc->Array.concat([`where('${field}', '<', '${s}'})`])
            | Query.Float(f) => acc->Array.concat([`where('${field}', '<', ${f->Float.toString}})`])
            }
          | Query.LTE(field, value) =>
            switch value {
            | Query.Boolean(b) =>
              acc->Array.concat([`where('${field}', '<=', ${b ? "true" : "false"}})`])
            | Query.Integer(i) =>
              acc->Array.concat([`where('${field}', '<=', ${i->Int.toString}})`])
            | Query.String(s) => acc->Array.concat([`where('${field}', '<=', ${s}})`])
            | Query.Float(f) =>
              acc->Array.concat([`where('${field}', '<=', ${f->Float.toString}})`])
            }
          | Query.Contains(field, value) =>
            switch value {
            | Query.Integer(i) =>
              acc->Array.concat([`where('${field}', 'array-contains', ${i->Int.toString}})`])
            | Query.String(s) => acc->Array.concat([`where('${field}', 'array-contains', '${s}'})`])
            | Query.Float(f) =>
              acc->Array.concat([`where('${field}', 'array-contains', ${f->Float.toString}})`])
            | _ => acc
            }
          | Query.InvalidCondition(_) => acc
          }
        }),
      )
    | SelectionPath(selections) =>
      acc->Array.concat(
        selections
        ->Selection.orders
        ->Array.reduce([], (acc, v) => {
          switch v {
          | Selection.Asc(Selection.FieldName(name)) => acc->Array.concat([`orderBy('${name}')`])
          | Selection.Desc(Selection.FieldName(name)) =>
            acc->Array.concat([`orderBy('${name}', 'desc')`])
          | _ => acc
          }
        }),
      )
    }
  )
  ->Js.Array2.joinWith(".")
}

let isEmpty = t => t->List.length == 0
