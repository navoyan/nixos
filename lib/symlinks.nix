_: {
  sources = base: rels:
    rels
    |> map (rel: {
      inherit base rel;
    });
}
