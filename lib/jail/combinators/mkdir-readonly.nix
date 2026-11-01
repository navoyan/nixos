{combinators, ...}:
with combinators; {
  mkdir-readonly = path:
    compose [
      (add-runtime
        # bash
        "mkdir -p ${escape path}")
      (readonly path)
    ];
}
