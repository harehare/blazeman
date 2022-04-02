open Test
open Belt

let intEqual = (~message=?, a: int, b: int) =>
  assertion(~message?, ~operator="intEqual", (a, b) => a === b, a, b)

let stringEqual = (~message=?, a: string, b: string) =>
  assertion(~message?, ~operator="stringEqual", (a, b) => a == b, a, b)

let boolEqual = (~message=?, a: bool, b: bool) =>
  assertion(~message?, ~operator="boolEqual", (a, b) => a === b, a, b)

let commandEq = (a, b) => {
  switch (a, b) {
  | (Command.Get(path1, format1), Command.Get(path2, format2)) =>
    path1->CollectionPath.toString == path2->CollectionPath.toString &&
      format1->Format.toString == format2->Format.toString

  | (
      Command.Docs(path1, format1, limit1, offset1),
      Command.Docs(path2, format2, limit2, offset2),
    ) =>
    path1->CollectionPath.toString == path2->CollectionPath.toString &&
    limit1->Option.getWithDefault(Limit.default)->Limit.unwrap ==
      limit2->Option.getWithDefault(Limit.default)->Limit.unwrap &&
    offset1->Option.getWithDefault(Offset.default)->Offset.unwrap ==
      offset2->Option.getWithDefault(Offset.default)->Offset.unwrap &&
    format1->Format.toString == format2->Format.toString

  | (Command.Set(path1, format1, json1), Command.Set(path2, format2, json2)) =>
    path1->CollectionPath.toString == path2->CollectionPath.toString &&
    json1->Js.Json.stringify == json2->Js.Json.stringify &&
    format1->Format.toString == format2->Format.toString

  | (Command.SetDryRun(path1, format1, json1), Command.SetDryRun(path2, format2, json2)) =>
    path1->CollectionPath.toString == path2->CollectionPath.toString &&
    json1->Js.Json.stringify == json2->Js.Json.stringify &&
    format1->Format.toString == format2->Format.toString

  | (Command.Update(path1, format1, json1), Command.Update(path2, format2, json2)) =>
    path1->CollectionPath.toString == path2->CollectionPath.toString &&
    json1->Js.Json.stringify == json2->Js.Json.stringify &&
    format1->Format.toString == format2->Format.toString

  | (Command.UpdateDryRun(path1, format1, json1), Command.UpdateDryRun(path2, format2, json2)) =>
    path1->CollectionPath.toString == path2->CollectionPath.toString &&
    json1->Js.Json.stringify == json2->Js.Json.stringify &&
    format1->Format.toString == format2->Format.toString

  | (Command.List(path1), Command.List(path2)) =>
    path1->Option.getWithDefault(CollectionPath.empty())->CollectionPath.toString ==
      path2->Option.getWithDefault(CollectionPath.empty())->CollectionPath.toString

  | (Command.Delete(path1), Command.Delete(path2)) =>
    path1->CollectionPath.toString == path2->CollectionPath.toString

  | (Command.DeleteDryRun(path1, format1), Command.DeleteDryRun(path2, format2)) =>
    path1->CollectionPath.toString == path2->CollectionPath.toString &&
      format1->Format.toString == format2->Format.toString

  | (Command.Help(_), Command.Help(_)) => true
  | (Command.Invalid(_), Command.Invalid(_)) => true
  | (Command.Version, Command.Version) => true
  | _ => false
  }
}

let commandEqual = (~message=?, a: Command.t, b: Command.t) =>
  assertion(~message?, ~operator="commandEqual", commandEq, a, b)

let queryEq = (a, b) => {
  switch (a, b) {
  | (Query.EQ(fieldName1, value1), Query.EQ(fieldName2, value2)) =>
    fieldName1 == fieldName2 && value1 == value2
  | (Query.NEQ(fieldName1, value1), Query.NEQ(fieldName2, value2)) =>
    fieldName1 == fieldName2 && value1 == value2
  | (Query.GT(fieldName1, value1), Query.GT(fieldName2, value2)) =>
    fieldName1 == fieldName2 && value1 == value2
  | (Query.GTE(fieldName1, value1), Query.GTE(fieldName2, value2)) =>
    fieldName1 == fieldName2 && value1 == value2
  | (Query.LT(fieldName1, value1), Query.LT(fieldName2, value2)) =>
    fieldName1 == fieldName2 && value1 == value2
  | (Query.LTE(fieldName1, value1), Query.LTE(fieldName2, value2)) =>
    fieldName1 == fieldName2 && value1 == value2
  | (Query.Contains(fieldName1, value1), Query.Contains(fieldName2, value2)) =>
    fieldName1 == fieldName2 && value1 == value2
  | (InvalidCondition(op1), InvalidCondition(op2)) => op1 == op2
  | _ => false
  }
}

let queryEqual = (~message=?, a: Query.t, b: Query.t) =>
  assertion(~message?, ~operator="queryEq", queryEq, a, b)

let queryEquals = (a: option<array<Query.t>>, b: option<array<Query.t>>) => {
  switch (a, b) {
  | (Some(queries1), Some(queries2)) =>
    if queries1->Array.length != queries2->Array.length {
      fail()
    } else {
      Array.zip(queries1, queries2)->Array.forEach(v => {
        let (a_, b_) = v
        queryEqual(a_, b_)
      })
    }
  | (None, None) => pass()
  | _ => fail()
  }
}

let selectionEq = (a: option<Selection.t>, b: option<Selection.t>) => {
  let selection1 = a->Option.getWithDefault([])
  let selection2 = b->Option.getWithDefault([])
  Array.eq(selection1, selection2, (v1, v2) =>
    switch (v1, v2) {
    | (Selection.Field(Selection.FieldName(f1)), Selection.Field(Selection.FieldName(f2))) =>
      f1 == f2
    | (Selection.Asc(Selection.FieldName(f1)), Selection.Asc(Selection.FieldName(f2))) => f1 == f2
    | (Selection.Desc(Selection.FieldName(f1)), Selection.Desc(Selection.FieldName(f2))) => f1 == f2
    | _ => false
    }
  )
}

let selectionEqual = (~message=?, a: option<Selection.t>, b: option<Selection.t>) =>
  assertion(~message?, ~operator="selectionEqual", selectionEq, a, b)
