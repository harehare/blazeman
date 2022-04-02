open Belt

type t = Limit(int)

let default = Limit(30)
let fromString = (s: string) =>
  s->Int.fromString->Option.mapWithDefault(default, v => Limit(v <= 0 ? 1 : v))

let unwrap = (limit: t): int => {
  let Limit(l) = limit
  l
}
