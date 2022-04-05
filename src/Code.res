type code = string
type t = array<code>

let initializeApp = [
  "const { initializeApp, applicationDefault, cert } = require('firebase-admin/app');",
  "const { getFirestore, Timestamp, FieldValue } = require('firebase-admin/firestore');",
  `const serviceAccount = require('${Env.credential}');`,
  "initializeApp({",
  "  credential: cert(serviceAccount)",
  "});",
  "const db = getFirestore();",
]

let rootList = () => [
  "const collections = await db.listCollections();",
  "console.log(doc.data());",
  "collections.forEach(collection => {",
  "  console.log(collection.id);",
  "});",
]

let listCollection = t => [
  `const dataRef = ${t->CollectionPath.toCode};`,
  "const collections = await dataRef.listCollections();",
  "collections.forEach(collection => {",
  "  console.log(collection.id);",
  "});",
]

let get = t => [
  `const dataRef = ${t->CollectionPath.toCode};`,
  "const doc = await dataRef.get();",
  "console.log(doc.data());",
]

let docs = (t, limit, offset) => {
  let ref = switch (limit, offset) {
  | (Some(limit), Some(offset)) =>
    `${t->CollectionPath.toCode}.${limit->Limit.toCode}.${offset->Offset.toCode}`
  | (Some(limit), None) => `${t->CollectionPath.toCode}.${limit->Limit.toCode}`
  | (None, Some(offset)) => `${t->CollectionPath.toCode}.${offset->Offset.toCode}`
  | (None, None) => t->CollectionPath.toCode
  }
  [
    `const dataRef = ${ref};`,
    "const snapshot = await dataRef.get();",
    "snapshot.forEach(doc => {",
    "  console.log(doc.id, '=>', doc.data());",
    "});",
  ]
}

let set = (t, json) => [
  `const dataRef = ${t->CollectionPath.toCode};`,
  `await dataRef.set('${json->Js.Json.stringify}');`,
  "console.log(res);",
]

let update = (t, json) => [
  `const dataRef = ${t->CollectionPath.toCode};`,
  `const res = await dataRef.set('${json->Js.Json.stringify}', {merge: true});`,
  "console.log(res);",
]

let delete = t => [
  `const dataRef = ${t->CollectionPath.toCode};`,
  `const res = await dataRef.delete();`,
  `console.log(res);`,
]

let toString = t => t->Js.Array2.joinWith("\n")
