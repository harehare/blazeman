open Belt
open NodeJs

let credential = %raw(`
	process.env.GOOGLE_APPLICATION_CREDENTIALS`)

let hasRequiredEnv = () => {
  switch Process.process->Process.env->Js.Dict.get("GOOGLE_APPLICATION_CREDENTIALS") {
  | Some(_) => Result.Ok()
  | None => Result.Error(Error.NoRequiredEnv("GOOGLE_APPLICATION_CREDENTIALS"))
  }
}
