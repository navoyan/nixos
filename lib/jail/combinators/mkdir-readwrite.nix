{combinators, ...}:
with combinators; {
  mkdir-readwrite = path:
    compose [
      (add-runtime
        # bash
        "mkdir -p ${escape path}")
      (readwrite path)
    ];
}
