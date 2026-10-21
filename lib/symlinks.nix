_: {
  mkSources = base: rels:
    rels
    |> map (rel: {
      inherit base rel;
    });
}
