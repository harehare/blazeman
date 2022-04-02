type t = DocId(string)

let fromString = (s: string) => DocId(s)
let unwrap = (docId: t): string => {
  let DocId(d) = docId
  d
}
