open Test

test("valid selection", () => {
  Assert.selectionEqual(
    Selection.fromString("{field1}"),
    Some([Selection.Field(Selection.FieldName("field1"))]),
  )
  Assert.selectionEqual(
    Selection.fromString("{field1,}"),
    Some([Selection.Field(Selection.FieldName("field1"))]),
  )
  Assert.selectionEqual(
    Selection.fromString("{ field1, field2, ^asc, _desc }"),
    Some([
      Selection.Field(Selection.FieldName("field1")),
      Selection.Field(Selection.FieldName("field2")),
      Selection.Asc(Selection.FieldName("asc")),
      Selection.Desc(Selection.FieldName("desc")),
    ]),
  )
})

test("invalid selection", () => {
  Assert.selectionEqual(Selection.fromString("field1, field2}"), None)
  Assert.selectionEqual(Selection.fromString("{field1, field2"), None)
})
