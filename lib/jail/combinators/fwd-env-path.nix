{combinators, ...}:
with combinators; {
  fwd-env-path = mount: envName:
    compose [
      (fwd-env envName)
      (mount (noescape ("\"$" + envName + "\"")))
    ];
}
