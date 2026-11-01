{combinators, ...}:
with combinators; {
  ro-symlink-and-target = symlink:
    compose [
      (readonly symlink)
      (add-runtime
        # bash
        ''
          SYMLINK_TARGET="$(readlink ${escape symlink})"
          RUNTIME_ARGS+=(--ro-bind "$SYMLINK_TARGET" "$SYMLINK_TARGET")
        '')
    ];
}
