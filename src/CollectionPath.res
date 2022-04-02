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

let isEmpty = t => t->List.length == 0
