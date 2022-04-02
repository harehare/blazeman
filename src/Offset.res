open Belt

type t = Offset(int)

let default = Offset(0)
let fromString = (s: string) =>
  s->Int.fromString->Option.mapWithDefault(default, v => Offset(v <= 0 ? 1 : v))

let unwrap = (offset: t): int => {
  let Offset(o) = offset
  o
}
