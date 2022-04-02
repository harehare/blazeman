open Belt

module StringCmp = Id.MakeComparable({
  type t = string
  let cmp = Pervasives.compare
})
