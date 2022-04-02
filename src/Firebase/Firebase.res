type firebase
type credential

module Firestore = Firebase_Firestore

module InstanceId = {
  type t

  module FirebaseApp = {
    type t
    module Options = {
      type t
      @get external projectId: t => string = "projectId"
    }
    @get external options: t => Options.t = "options"
  }

  @get external app: t => FirebaseApp.t = "app"
}

@module("firebase-admin/app") external initializeApp: credential => unit = "initializeApp"

@module("firebase-admin/app") external applicationDefault: unit => credential = "applicationDefault"

@module("firebase-admin/app") external cert: string => credential = "cert"

@module("firebase-admin") external instanceId: unit => InstanceId.t = "instanceId"
