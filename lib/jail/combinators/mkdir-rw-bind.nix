{combinators, ...}:
with combinators; {
  mkdir-rw-bind = from: to:
    compose [
      (add-runtime
        # bash
        "mkdir -p ${escape from}")
      (rw-bind from to)
    ];
}
