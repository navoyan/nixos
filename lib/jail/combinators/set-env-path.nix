{combinators, ...}:
with combinators; {
  set-env-path = mount: envName: path:
    compose [
      (set-env envName path)
      (mount path)
    ];
}
