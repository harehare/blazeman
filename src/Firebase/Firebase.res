open NodeJs

type firebase
type credential

module Firestore = Firebase_Firestore

@module("firebase-admin/app") external initializeApp: credential => unit = "initializeApp"

@module("firebase-admin/app") external applicationDefault: unit => credential = "applicationDefault"

@module("firebase-admin/app") external cert: string => credential = "cert"

type serviceAccount = {project_id: string}
@scope("JSON") @val
external parseIntoServiceAccount: string => serviceAccount = "parse"

let projectId = () =>
  parseIntoServiceAccount(Fs.readFileSync(Env.credential)->Buffer.toString).project_id
