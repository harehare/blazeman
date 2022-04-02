type fieldName = string
type invalidOperator = string

type value = Boolean(bool) | String(string) | Integer(int) | Float(float)

type t =
  | EQ(fieldName, value)
  | NEQ(fieldName, value)
  | GT(fieldName, value)
  | GTE(fieldName, value)
  | LT(fieldName, value)
  | LTE(fieldName, value)
  | Contains(fieldName, value)
  | InvalidCondition(invalidOperator)

let operator = t => {
  switch t {
  | EQ(_) => "=="
  | NEQ(_) => "!="
  | GT(_) => ">"
  | GTE(_) => ">="
  | LT(_) => "<"
  | LTE(_) => "<="
  | Contains(_) => "contains"
  | InvalidCondition(op) => op
  }
}

let from = (name, op, value: 'a) => {
  switch op {
  | "==" => EQ(name, value)
  | "!=" => NEQ(name, value)
  | ">" => GT(name, value)
  | ">=" => GTE(name, value)
  | "<" => LT(name, value)
  | "<=" => LTE(name, value)
  | "contains" => Contains(name, value)
  | _ => InvalidCondition(op)
  }
}

let stringValue = value => {
  value->Js.String2.startsWith("'") && value->Js.String2.startsWith("'")
    ? Some(value->Js.String2.slice(~from=1, ~to_=-1))
    : None
}

let toValue = (name, operator, value): option<t> => {
  switch value {
  | "true" => Some(from(name, operator, Boolean(true)))
  | "false" => Some(from(name, operator, Boolean(false)))
  | _ =>
    switch value->stringValue {
    | Some(s) => Some(from(name, operator, String(s)))
    | None =>
      switch value->int_of_string_opt {
      | Some(i) => Some(from(name, operator, Integer(i)))
      | _ =>
        switch value->float_of_string_opt {
        | Some(f) => Some(from(name, operator, Float(f)))
        | _ => Some(from(name, operator, String(value)))
        }
      }
    }
  }
}

let fromString = (query, op) => {
  switch query->Js.String2.split(op) {
  | [name, value] => toValue(name->Js.String2.trim, op, value->Js.String2.trim)
  | _ => None
  }
}

let fromQueryString = queries => {
  if queries->Js.String2.startsWith("[") && queries->Js.String2.endsWith("]") {
    Some(
      queries
      ->Js.String2.slice(~from=1, ~to_=-1)
      ->Js.String2.split(",")
      ->Belt.Array.keepMap(query => {
        switch (
          query->fromString("=="),
          query->fromString("!="),
          query->fromString(">="),
          query->fromString(">"),
          query->fromString("<="),
          query->fromString("<"),
          query->fromString("contains"),
        ) {
        | (Some(EQ(n, v)), _, _, _, _, _, _) => Some(EQ(n,v))
        | (_, Some(NEQ(n, v)), _, _, _, _, _) => Some(NEQ(n, v))
        | (_, _, Some(GTE(n, v)), _, _, _, _) => Some(GTE(n, v))
        | (_, _, _, Some(GT(n, v)), _, _, _) => Some(GT(n, v))
        | (_, _, _, _, Some(LTE(n, v)), _, _) => Some(LTE(n, v))
        | (_, _, _, _, _, Some(LT(n, v)), _) => Some(LT(n, v))
        | (_, _, _, _, _, _, Some(Contains(n, v))) => Some(Contains(n, v))
        | _ => Some(InvalidCondition(query))
        }
      }),
    )
  } else {
    None
  }
}
