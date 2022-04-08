type t = Pagination(Offset.t, Limit.t) | Cursor(StartAt.t)

let default = Pagination(Offset.default, Limit.default)
let from = (limit: option<Limit.t>, offset: option<Offset.t>, startAt: option<StartAt.t>) => {
  switch (offset, limit, startAt) {
  | (Some(_), Some(_), Some(_)) => Pagination(Offset.default, Limit.default)
  | (Some(o), Some(l), None) => Pagination(o, l)
  | (Some(o), None, None) => Pagination(o, Limit.default)
  | (None, Some(l), None) => Pagination(Offset.default, l)
  | (None, None, Some(s)) => Cursor(s)
  | _ => Pagination(Offset.default, Limit.default)
  }
}

let toCode = t =>
  switch t {
  | Pagination(offset, limit) => `${offset->Offset.toCode}.${limit->Limit.toCode}`
  | Cursor(startAt) => startAt->StartAt.toCode
  }
