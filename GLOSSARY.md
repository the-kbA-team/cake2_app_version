# AppVersion

The application version identifies the source state from which an application
was deployed or is being developed.

## Language

**Version identifier**:
The human-readable identifier of the application source state: a release
version for a tagged deployment or a Git ref or branch name otherwise.
_Avoid_: Branch, when referring to the identifier in all environments.

**Commit identifier**:
The abbreviated Git commit SHA identifying the application source state.

**Application version**:
The combination of the version identifier and commit identifier describing an
application source state.
