open Belt

type t = StartAt(array<string>)

let fromString = (s: string) => StartAt(
  s->Js.String2.split(",")->Array.map(f => f->Js.String2.trim),
)

let toCode = t => {
  let StartAt(fields) = t
  `startAt(${fields->Array.map(f => `"${f}"`)->Js.Array2.joinWith(",")})`
}

let toArray = t => {
  let StartAt(s) = t
  s
}
