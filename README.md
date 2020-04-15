# Okta plugin

This plugin provides command line completions for the
[`aws-okta`](https://github.com/segmentio/aws-okta) and
[`okta-awscli`](https://github.com/jmhale/okta-awscli) commands. Note that the
`aws-okta` command has been put on what the author refers to as an
[indefinite hiatus](https://github.com/segmentio/aws-okta/issues/278).

This plugin provides the following convenience functions.

| Function | Purpose |
| --- | --- |
| `aop <profile>` | Execute `aws-okta env <profile>` and set the token in the current shell |

To use the plugin, add `okta` to the plugins array in your zshrc file:

```zsh
plugins=(... okta)
```
