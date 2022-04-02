open Test

test("eq query", () => {
  Assert.queryEquals(
    Query.fromQueryString("[field1==value1]"),
    Some([Query.EQ("field1", Query.String("value1"))]),
  )

  Assert.queryEquals(
    Query.fromQueryString(
      "[field1==value1, field2 == 1, field3 == false, field4 ==  true, field5 == 0.1]",
    ),
    Some([
      Query.EQ("field1", Query.String("value1")),
      Query.EQ("field2", Query.Integer(1)),
      Query.EQ("field3", Query.Boolean(false)),
      Query.EQ("field4", Query.Boolean(true)),
      Query.EQ("field5", Query.Float(0.1)),
    ]),
  )

  Assert.queryEquals(Query.fromQueryString("field1==value1]"), None)
})

test("neq query", () => {
  Assert.queryEquals(
    Query.fromQueryString("[field1!=value1]"),
    Some([Query.NEQ("field1", Query.String("value1"))]),
  )
})

test("gt query", () => {
  Assert.queryEquals(
    Query.fromQueryString("[field1 > value1]"),
    Some([Query.GT("field1", Query.String("value1"))]),
  )
})

test("gte query", () => {
  Assert.queryEquals(
    Query.fromQueryString("[field1 >= value1]"),
    Some([Query.GTE("field1", Query.String("value1"))]),
  )
})

test("lt query", () => {
  Assert.queryEquals(
    Query.fromQueryString("[field1 < value1]"),
    Some([Query.LT("field1", Query.String("value1"))]),
  )
})

test("lte query", () => {
  Assert.queryEquals(
    Query.fromQueryString("[field1 <= value1]"),
    Some([Query.LTE("field1", Query.String("value1"))]),
  )
})

test("Contains query", () => {
  Assert.queryEquals(
    Query.fromQueryString("[field1 contains value1]"),
    Some([Query.Contains("field1", Query.String("value1"))]),
  )
})

test("InvalidCondition query", () => {
  Assert.queryEquals(
    Query.fromQueryString("[field1 ! value1]"),
    Some([Query.InvalidCondition("field1 ! value1")]),
  )
})
