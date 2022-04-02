open Belt

type fieldName = FieldName(string)
type selection = Field(fieldName) | Asc(fieldName) | Desc(fieldName)
type t = array<selection>

let fromString = query => {
  if query->Js.String2.startsWith("{") && query->Js.String2.endsWith("}") {
    Some(
      query
      ->Js.String2.slice(~from=1, ~to_=-1)
      ->Js.String2.split(",")
      ->Array.keepMap(f =>
        switch f->Js.String2.trim {
        | "" => None
        | v =>
          if v->Js.String2.startsWith("^") {
            Some(Asc(FieldName(v->Js.String2.slice(~from=1, ~to_=v->Js.String2.length))))
          } else if v->Js.String2.startsWith("_") {
            Some(Desc(FieldName(v->Js.String2.slice(~from=1, ~to_=v->Js.String2.length))))
          } else {
            Some(Field(FieldName(v)))
          }
        }
      ),
    )
  } else {
    None
  }
}

let fieldNames = t => {
  t->Array.keepMap(v =>
    switch v {
    | Field(fieldName) => Some(fieldName)
    | _ => None
    }
  )
}

let orders = t => {
  t->Array.keepMap(v =>
    switch v {
    | Asc(fieldName) => Some(Asc(fieldName))
    | Desc(fieldName) => Some(Desc(fieldName))
    | _ => None
    }
  )
}

let toFieldName = fieldName => {
  let FieldName(n) = fieldName
  n
}
