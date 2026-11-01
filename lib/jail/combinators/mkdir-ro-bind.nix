{combinators, ...}:
with combinators; {
  mkdir-ro-bind = from: to:
    compose [
      (add-runtime
        # bash
        "mkdir -p ${escape from}")
      (ro-bind from to)
    ];
}
