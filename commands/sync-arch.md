# /sync-arch — Update Architecture Documentation

Focused update of `ARCHITECTURE.md`. Use after structural changes (new components, config changes, dependency updates).

## Arguments

Parse `$ARGUMENTS`:
- If empty: write to `docs/` in current git repo root (`git rev-parse --show-toplevel`)
- If a local path: write to `<path>/docs/`
- `--push`: auto-push after commit
- `--project <name>`: scope to `docs/<name>/ARCHITECTURE.md`

Examples:
```
/sync-arch                                      # <git-root>/docs/ARCHITECTURE.md
/sync-arch --push                               # same + push
/sync-arch ~/other-repo --push
/sync-arch ~/infra-docs --project myapp --push
```

## Steps
1. Parse arguments, resolve target to `<root>/docs/` directory
2. Read existing `docs/ARCHITECTURE.md` (create if missing)
3. Scan conversation and codebase for architectural changes:
   - New/removed components
   - Changed data flows
   - Config changes (read actual config files, not from memory)
   - Dependency version changes
4. Update ARCHITECTURE.md (merge, preserve valid existing content)
5. Git add + commit: `docs: architecture update [YYYY-MM-DD HH:MM]`
6. If `--push`: git push
7. Summary of architectural changes captured
