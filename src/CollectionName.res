type t = CollectionName(string)

let fromString = (s: string) => CollectionName(s)
let unwrap = (name: t): string => {
  let CollectionName(name) = name
  name
}
