open Test

test("toString", () => {
  Assert.stringEqual(
    CollectionPath.fromString("/collection1/docId1/collection2/docId2")->CollectionPath.toString,
    "/collection1/docId1/collection2/docId2",
  )

  Assert.stringEqual(
    CollectionPath.fromString(
      "/collection1/docId1/collection2/docId2/[test==1]",
    )->CollectionPath.toString,
    "/collection1/docId1/collection2/docId2",
  )

  Assert.stringEqual(
    CollectionPath.fromString(
      "/collection1/docId1/collection2/docId2/[test>=1]",
    )->CollectionPath.toString,
    "/collection1/docId1/collection2/docId2",
  )

  Assert.stringEqual(
    CollectionPath.fromString(
      "/collection1/docId1/collection2/docId2/[test>1]",
    )->CollectionPath.toString,
    "/collection1/docId1/collection2/docId2",
  )

  Assert.stringEqual(
    CollectionPath.fromString(
      "/collection1/docId1/collection2/docId2/[test<=1]",
    )->CollectionPath.toString,
    "/collection1/docId1/collection2/docId2",
  )

  Assert.stringEqual(
    CollectionPath.fromString(
      "/collection1/docId1/collection2/docId2/[test<1]",
    )->CollectionPath.toString,
    "/collection1/docId1/collection2/docId2",
  )

  Assert.stringEqual(
    CollectionPath.fromString(
      "/collection1/docId1/collection2/docId2/[test!=1]/{filed1, field2}",
    )->CollectionPath.toString,
    "/collection1/docId1/collection2/docId2",
  )

  Assert.stringEqual(
    CollectionPath.fromString(
      "/collection1/docId1/collection2/docId2/collection3/[test!=1]/{filed1, field2}",
    )->CollectionPath.toString,
    "/collection1/docId1/collection2/docId2/collection3",
  )

  Assert.stringEqual(
    CollectionPath.fromString(
      "/collection1/docId1/collection2/docId2/collection3/docId3/[test!=1]/{filed1, field2}",
    )->CollectionPath.toString,
    "/collection1/docId1/collection2/docId2/collection3/docId3",
  )

  Assert.stringEqual(
    CollectionPath.fromString(
      "/collection1/docId1/collection2/docId2/collection3/docId3/collection4/docId4/collection5/docId5/collection6/[test!=1]/{filed1, field2}",
    )->CollectionPath.toString,
    "/collection1/docId1/collection2/docId2/collection3/docId3/collection4/docId4/collection5/docId5/collection6",
  )
})
